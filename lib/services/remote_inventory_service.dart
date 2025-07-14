import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteInventoryService {
  static const String baseUrl =
      'http://192.168.83.117/sumatra_api/get_inventory.php';

  Future<List<Map<String, dynamic>>> getInventoryList() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Gagal memuat data inventory: \\${response.statusCode}');
    }
  }

  Future<bool> deleteInventory(int inventoryId) async {
    final url = Uri.parse(
      'http://192.168.83.117/sumatra_api/delete_inventory.php',
    );
    final response = await http.post(url, body: {'id': inventoryId.toString()});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  Future<bool> updateInventory(Map<String, dynamic> data) async {
    final url = Uri.parse(
      'http://192.168.83.117/sumatra_api/update_inventory.php',
    );
    final response = await http.post(url, body: data);
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      return res['success'] == true;
    }
    return false;
  }
}
