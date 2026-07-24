import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/constants.dart'; // Might be necessary

class AppSheetService {
  final String tableName = 'TGF Inventory Database';

  Uri _getUri() {
    return Uri.parse('${AppConfig.baseUrl}/$tableName/Action');
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'applicationAccessKey': AppConfig.appsheetAccessKey,
    };
  }

  Future<List<String>> fetchItemNames(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/Items/Action'),
        headers: {
          'ApplicationAccessKey': AppConfig.appsheetAccessKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "Action": "Find",
          "Properties": {
            "Locale": "en-US",
            "Timezone": "Standard Time"
          },
          "Selector": "Filter(Items, CONTAINS([Item], \"$query\"))"
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item['Item'].toString()).toList();
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
    }
    return [];
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
    required String logId, // Key required here to locate the row #
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

  // Remove log
  Future<bool> deleteStockLog(String logId) async {
    final body = jsonEncode({
      "Action": "Delete",
      "Properties": {"Locale": "en-US"},
      "Rows": [
        {
          "LogID": logId
        }
      ]
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

  // returns a fully summarized list of all products (grouped and summed)
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