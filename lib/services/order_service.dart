import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderService {
  static const String _orderKey = 'orders';

  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersRaw = prefs.getString(_orderKey);
    if (ordersRaw == null) return [];
    final List<dynamic> data = jsonDecode(ordersRaw);
    return data.map((json) => Order.fromJson(json)).toList();
  }

  Future<void> addOrder(Order order) async {
    final orders = await getOrders();
    orders.add(order);
    await _saveOrders(orders);
  }

  Future<void> updateOrder(Order order) async {
    final orders = await getOrders();
    final idx = orders.indexWhere((o) => o.id == order.id);
    if (idx >= 0) {
      orders[idx] = order;
      await _saveOrders(orders);
    }
  }

  Future<void> deleteOrder(String id) async {
    final orders = await getOrders();
    orders.removeWhere((o) => o.id == id);
    await _saveOrders(orders);
  }

  Future<Order?> getOrderById(String id) async {
    final orders = await getOrders();
    try {
      return orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersRaw = jsonEncode(orders.map((o) => o.toJson()).toList());
    await prefs.setString(_orderKey, ordersRaw);
  }
}
