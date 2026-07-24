import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class BulletinService {
  static const String bulletinTable = "Bulletin Board";

  Uri _getUri(String table) {
    return Uri.parse('${AppConfig.bulletinBaseUrl}/$table/Action');
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'applicationAccessKey': AppConfig.bulletinAppsheetAccessKey,
    };
  }

  Future<bool> createBulletinPost({
    required String user,
    required String comment,
  }) async {
    final body = jsonEncode({
      "Action": "Add",
      "Properties": {"Locale": "en-US"},
      "Rows": [
        {
          "LogID": DateTime.now().millisecondsSinceEpoch
              .toString(), // Ensures a primary key is always provided
          "User": user,
          "Comment": comment,
          "Timestamp": DateTime.now().toIso8601String(),
        },
      ],
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
      "Rows": [],
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
    final keyVal =
        postRow['ID'] ??
        postRow['id'] ??
        postRow['Row ID'] ??
        postRow['_RowNumber'] ??
        postRow.values.first;

    final keyName = postRow.containsKey('ID')
        ? 'ID'
        : postRow.containsKey('id')
        ? 'id'
        : postRow.containsKey('Row ID')
        ? 'Row ID'
        : postRow.containsKey('_RowNumber')
        ? '_RowNumber'
        : 'ID';

    final body = jsonEncode({
      "Action": "Delete",
      "Properties": {"Locale": "en-US"},
      "Rows": [
        {keyName: keyVal},
      ],
    });

    final response = await http.post(
      _getUri(bulletinTable),
      headers: _getHeaders(),
      body: body,
    );

    return response.statusCode == 200;
  }
}
