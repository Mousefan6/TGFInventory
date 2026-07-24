import 'dart:convert';
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
      'applicationAccessKey': AppConfig.appsheetAccessKey,
    };
  }

  // ==========================
  // Inventory Functions
  // ==========================

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

  Future<bool> deleteStockLog(String logId) async {
    final body = jsonEncode({
      "Action": "Delete",
      "Properties": {"Locale": "en-US"},
      "Rows": [
        {
          "LogID": logId,
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
  Future<bool> createBulletinPost({
    required String user,
    required String comment,
  }) async {
    final body = jsonEncode({
      "Action": "Add",
      "Properties": {"Locale": "en-US"},
      "Rows": [
        {
          "User": user,
          "Comment": comment,
        }
      ]
    });

    print("URL: ${_getUri(bulletinTable)}");
    print("Headers: ${_getHeaders()}");
    print("Body: $body");

    final response = await http.post(
      _getUri(bulletinTable),
      headers: _getHeaders(),
      body: body,
    );

    print("Status: ${response.statusCode}");
    print("Response: '${response.body}'");

    return response.statusCode == 200;
  }
}