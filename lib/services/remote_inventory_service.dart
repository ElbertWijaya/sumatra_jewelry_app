import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteInventoryService {
  static const String baseUrl = 'http://192.168.187.174/sumatra_api/get_inventory.php';

  Future<List<Map<String, dynamic>>> getInventoryList() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Gagal memuat data inventory: \\${response.statusCode}');
    }
  }
}
