import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class InventoryService {
  static const String inventoryTable = "TGF Inventory Database";
  static const String bulletinTable = "TGF Inventory Database: Bulletin Board";

  Uri _getUri([String? tableName]) {
    final targetTable = tableName ?? inventoryTable;
    return Uri.parse('${AppConfig.baseUrl}/$targetTable/Action');
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
        _getUri(inventoryTable),
        headers: _getHeaders(),
        body: jsonEncode({
          "Action": "Find",
          "Properties": {"Locale": "en-US"},
          "Selector": "Filter($inventoryTable, CONTAINS([Item], \"$trimmed\"))"
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

    throw Exception("Failed to fetch records: ${response.statusCode}");
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

  // Summarized list of all products
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
  // Bulletin Board Methods
  // ==========================

  Future<bool> createBulletinPost({required String user, required String comment}) async {
    final body = jsonEncode({
      "Action": "Add",
      "Properties": {"Locale": "en-US"},
      "Rows": [
        {
          "LogID": DateTime.now().millisecondsSinceEpoch.toString(),
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

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
    }

    return [];
  }

  Future<bool> deleteBulletinPost(Map<String, dynamic> postRow) async {
    final keyVal = postRow['LogID'] ??
        postRow['ID'] ??
        postRow['id'] ??
        postRow['Row ID'] ??
        postRow['_RowNumber'] ??
        postRow.values.first;

    final keyName = postRow.containsKey('LogID') ? 'LogID' :
    postRow.containsKey('ID') ? 'ID' :
    postRow.containsKey('id') ? 'id' :
    postRow.containsKey('Row ID') ? 'Row ID' :
    postRow.containsKey('_RowNumber') ? '_RowNumber' : 'LogID';

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