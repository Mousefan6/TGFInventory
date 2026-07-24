import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AppSheetService {
  final String tableName = 'TGF Inventory Database';

  Uri _getUri() {
    return Uri.parse('${AppConfig.baseUrl}/$tableName/Action');
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'ApplicationAccessKey': AppConfig.appsheetAccessKey,
    };
  }

  // Fetch unique item names for autocomplete
  Future<List<String>> fetchItemNames(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final response = await http.post(
        _getUri(),
        headers: _getHeaders(),
        body: jsonEncode({
          "Action": "Find",
          "Properties": {"Locale": "en-US"},
          "Selector": "Filter($tableName, CONTAINS([Item], \"$trimmed\"))"
        }),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          final Set<String> uniqueNames = {};
          for (var item in decoded) {
            final name = item['Item']?.toString() ?? '';
            if (name.isNotEmpty) uniqueNames.add(name);
          }
          return uniqueNames.toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching item names: $e');
    }
    return [];
  }

  // Fetch unique user names for autocomplete
  Future<List<String>> fetchUserNames(String query) async {
    try {
      final logs = await readAllLogs();
      final Set<String> uniqueUsers = {};

      for (var log in logs) {
        final userName = log['User']?.toString().trim() ?? '';
        if (userName.isNotEmpty) {
          uniqueUsers.add(userName);
        }
      }

      if (query.trim().isEmpty) {
        return uniqueUsers.toList();
      }

      final lowerQuery = query.toLowerCase();
      return uniqueUsers
          .where((user) => user.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user names: $e');
      return [];
    }
  }

  // Create new stock item
  Future<bool> createStockLog({
    required String item,
    required int quantity,
    required String user,
    required String comment,
  }) async {
    final body = jsonEncode({
      "Action": "Add",
      "Properties": {"Locale": "en-US"},
      "Rows": [
        {
          "Item": item,
          "Quantity": quantity,
          "User": user,
          "Comment": comment,
        }
      ]
    });

    final response = await http.post(_getUri(), headers: _getHeaders(), body: body);
    return response.statusCode == 200;
  }

  // Read logs for cards
  Future<List<Map<String, dynamic>>> readAllLogs() async {
    final body = jsonEncode({
      "Action": "Find",
      "Properties": {"Locale": "en-US"},
      "Rows": []
    });

    final response = await http.post(_getUri(), headers: _getHeaders(), body: body);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(decoded);
    } else {
      throw Exception('Failed to fetch records: ${response.statusCode}');
    }
  }

  // Update logs
  Future<bool> updateStockLog({
    required String logId,
    required String item,
    required int quantity,
    required String user,
    required String comment,
  }) async {
    final body = jsonEncode({
      "Action": "Edit",
      "Properties": {"Locale": "en-US"},
      "Rows": [
        {
          "LogID": logId,
          "Item": item,
          "Quantity": quantity,
          "User": user,
          "Comment": comment,
        }
      ]
    });

    final response = await http.post(_getUri(), headers: _getHeaders(), body: body);
    return response.statusCode == 200;
  }

  // TODO: Add a button that allows the user to remove a log/item completely from database
  // Remove log
  Future<bool> deleteStockLog(String logId) async {
    final body = jsonEncode({
      "Action": "Delete",
      "Properties": {"Locale": "en-US"},
      "Rows": [{"LogID": logId}]
    });

    final response = await http.post(_getUri(), headers: _getHeaders(), body: body);
    return response.statusCode == 200;
  }

  // Function to get total stock for specific item given name
  Future<int> getItemStockCount(String itemName) async {
    final allLogs = await readAllLogs();
    int currentTotalStock = 0;

    for (var row in allLogs) {
      if ((row['Item'] ?? row['name']) == itemName) {
        final rawQty = row['Quantity'];
        currentTotalStock += rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 0;
      }
    }
    return currentTotalStock;
  }

  // Summarized list of all products (grouped and summed)
  Future<List<Map<String, dynamic>>> getAggregatedInventory() async {
    final rawData = await readAllLogs();
    final Map<String, int> inventoryMap = {};

    for (var row in rawData) {
      final String itemName = row['Item'] ?? row['name'] ?? 'Unknown Product';
      final rawQty = row['Quantity'];
      final int parsedQty = rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 0;

      inventoryMap[itemName] = (inventoryMap[itemName] ?? 0) + parsedQty;
    }

    final List<Map<String, dynamic>> flatInventory = [];
    inventoryMap.forEach((name, totalQuantity) {
      if (totalQuantity > 0) {
        flatInventory.add({
          'Item': name,
          'Quantity': totalQuantity,
        });
      }
    });

    return flatInventory;
  }
}