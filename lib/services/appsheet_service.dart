import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AppSheetService {
  // Fetch all rows from Table 1
  Future<List<dynamic>> getInventoryItems() async {
    final url = Uri.parse('${AppConfig.baseUrl}/Table 1/Action');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'applicationAccessKey': AppConfig.appsheetAccessKey,
      },
      body: jsonEncode({
        "Action": "Find",
        "Properties": {
          "Locale": "en-US",
        },
        "Rows": []
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch data from AppSheet');
    }
  }
}