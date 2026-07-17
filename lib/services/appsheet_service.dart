import 'dart:convert';
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
      'applicationAccessKey': AppConfig.appsheetAccessKey,
    };
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
}