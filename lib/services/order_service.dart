import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderService {
  static const String baseUrl = 'http://192.168.176.165/sumatra_api/orders.php';

  Future<List<Order>> getOrders() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat pesanan: ${response.statusCode}');
    }
  }

  Future<void> addOrder(Order order) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': order.id,
        'customer_name': order.customerName,
        'customer_contact': order.customerContact,
        'address': order.address,
        'jewelry_type': order.jewelryType,
        'created_at': order.createdAt.toIso8601String(),
        // Tambahkan field lain jika endpoint PHP sudah mendukung
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menambah pesanan: ${response.body}');
    }
    final result = json.decode(response.body);
    if (result['success'] != true) {
      throw Exception('Gagal menambah pesanan (API): ${response.body}');
    }
  }

    Future<void> updateOrder(Order order) async {
    final response = await http.put(
      Uri.parse('$baseUrl?id=${order.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': order.id,
        'customer_name': order.customerName,
        'customer_contact': order.customerContact,
        'address': order.address,
        'jewelry_type': order.jewelryType,
        'created_at': order.createdAt.toIso8601String(),
        'updated_at': order.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        // Tambahkan field lain sesuai kebutuhan dan endpoint PHP
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal update pesanan: ${response.body}');
    }
    final result = json.decode(response.body);
    if (result['success'] != true) {
      throw Exception('Gagal update pesanan (API): ${response.body}');
    }
  }

  Future<void> deleteOrder(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl?id=$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pesanan: ${response.body}');
    }
    final result = json.decode(response.body);
    if (result['success'] != true) {
      throw Exception('Gagal menghapus pesanan (API): ${response.body}');
    }
  }

  Future<Order?> getOrderById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl?id=$id'));
    if (response.statusCode == 200) {
      if (response.body.isEmpty) return null;
      final dynamic data = json.decode(response.body);
      if (data == null) return null;
      if (data is List && data.isNotEmpty) {
        return Order.fromJson(Map<String, dynamic>.from(data[0]));
      }
      if (data is Map && data.isNotEmpty) {
        return Order.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } else {
      throw Exception('Gagal memuat pesanan: ${response.statusCode}');
    }
  }
}