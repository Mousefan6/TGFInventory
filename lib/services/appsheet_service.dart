import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AppSheetService {
  static const String inventoryTable = "TGF Inventory Database";
  static const String bulletinTable = "Bulletin Board";

  Uri _getUri(String table) {
    return Uri.parse('${AppConfig.baseUrl}/$table/Action');
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

    final response = await http.post(
      _getUri(inventoryTable),
      headers: _getHeaders(),
      body: body,
    );

    return response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> readAllLogs() async {
    final body = jsonEncode({
      "Action": "Find",
      "Properties": {"Locale": "en-US"},
      "Rows": []
    });

    final response = await http.post(
      _getUri(inventoryTable),
      headers: _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(decoded);
    }

    throw Exception("Failed to fetch records");
  }

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

    final response = await http.post(
      _getUri(inventoryTable),
      headers: _getHeaders(),
      body: body,
    );

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

    final response = await http.post(
      _getUri(inventoryTable),
      headers: _getHeaders(),
      body: body,
    );

    return response.statusCode == 200;
  }

  Future<int> getItemStockCount(String itemName) async {
    final allLogs = await readAllLogs();

    int total = 0;

    for (var row in allLogs) {
      if ((row["Item"] ?? row["name"]) == itemName) {
        final qty = row["Quantity"];
        total += qty is int ? qty : int.tryParse(qty.toString()) ?? 0;
      }
    }

    return total;
  }

  // Summarized list of all products (grouped and summed)
  Future<List<Map<String, dynamic>>> getAggregatedInventory() async {
    final rawData = await readAllLogs();

    final Map<String, int> inventoryMap = {};

    for (var row in rawData) {
      final item = row["Item"] ?? row["name"] ?? "Unknown";
      final qty = row["Quantity"];
      final parsedQty =
      qty is int ? qty : int.tryParse(qty.toString()) ?? 0;

      inventoryMap[item] = (inventoryMap[item] ?? 0) + parsedQty;
    }

    final List<Map<String, dynamic>> inventory = [];

    inventoryMap.forEach((item, qty) {
      if (qty > 0) {
        inventory.add({
          "Item": item,
          "Quantity": qty,
        });
      }
    });

    return inventory;
  }

  // ==========================
  // Bulletin Board
  // ==========================

  Future<bool> createBulletinPost({required String user, required String comment}) async {
    final body = jsonEncode({
      "Action": "Add",
      "Properties": {"Locale": "en-US"},
      "Rows": [
        {
          "LogID": DateTime.now().millisecondsSinceEpoch.toString(), // Ensures a primary key is always provided
          "User": user,
          "Comment": comment,
          "Timestamp": DateTime.now().toIso8601String(),
        }
      ]
    });

    final response = await http.post(
      _getUri(bulletinTable),
      headers: _getHeaders(),
      body: body,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<Map<String, dynamic>>> readAllBulletinPosts() async {
    final body = jsonEncode({
      "Action": "Find",
      "Properties": {"Locale": "en-US"},
      "Rows": []
    });

    final response = await http.post(
      _getUri(bulletinTable),
      headers: _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(decoded);
    }

    throw Exception("Failed to fetch bulletin posts");
  }

  Future<bool> deleteBulletinPost(Map<String, dynamic> postRow) async {
    // Dynamically look for the correct row key returned by AppSheet
    final keyVal = postRow['ID'] ??
        postRow['id'] ??
        postRow['Row ID'] ??
        postRow['_RowNumber'] ??
        postRow.values.first;

    final keyName = postRow.containsKey('ID') ? 'ID' :
    postRow.containsKey('id') ? 'id' :
    postRow.containsKey('Row ID') ? 'Row ID' :
    postRow.containsKey('_RowNumber') ? '_RowNumber' : 'ID';

    final body = jsonEncode({
      "Action": "Delete",
      "Properties": {"Locale": "en-US"},
      "Rows": [
        {
          keyName: keyVal,
        }
      ]
    });

    final response = await http.post(
      _getUri(bulletinTable),
      headers: _getHeaders(),
      body: body,
    );

    return response.statusCode == 200;
  }
}