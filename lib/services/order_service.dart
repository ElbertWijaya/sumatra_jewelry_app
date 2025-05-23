import 'package:flutter/foundation.dart';
import '../models/order.dart';

/// Dummy OrderService for demonstration and future backend integration.
/// In production, replace all dummy logic with real API calls and error handling.
class OrderService {
  static final OrderService _instance = OrderService._internal();

  factory OrderService() => _instance;

  OrderService._internal();

  final List<Order> _dummyOrders = [];

  /// Fetches a copy of all orders.
  Future<List<Order>> getOrders() async {
    try {
      // TODO: Replace with real API request.
      await Future.delayed(const Duration(milliseconds: 500));
      return List<Order>.from(_dummyOrders);
    } catch (e, stack) {
      debugPrint('OrderService.getOrders error: $e\n$stack');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Adds a new order.
  Future<void> addOrder(Order order) async {
    try {
      // TODO: Replace with real API request.
      await Future.delayed(const Duration(milliseconds: 500));
      _dummyOrders.add(order);
    } catch (e, stack) {
      debugPrint('OrderService.addOrder error: $e\n$stack');
      rethrow;
    }
  }

  /// Updates an existing order by ID.
  Future<void> updateOrder(Order order) async {
    try {
      // TODO: Replace with real API request.
      await Future.delayed(const Duration(milliseconds: 500));
      final idx = _dummyOrders.indexWhere((o) => o.id == order.id);
      if (idx != -1) {
        _dummyOrders[idx] = order;
      } else {
        throw Exception('Order not found');
      }
    } catch (e, stack) {
      debugPrint('OrderService.updateOrder error: $e\n$stack');
      rethrow;
    }
  }

  /// Removes an order by ID.
  Future<void> deleteOrder(String orderId) async {
    try {
      // TODO: Replace with real API request.
      await Future.delayed(const Duration(milliseconds: 500));
      _dummyOrders.removeWhere((o) => o.id == orderId);
    } catch (e, stack) {
      debugPrint('OrderService.deleteOrder error: $e\n$stack');
      rethrow;
    }
  }

  /// Fetches a single order by ID.
  Future<Order?> getOrderById(String orderId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _dummyOrders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );
    } catch (e, stack) {
      debugPrint('OrderService.getOrderById error: $e\n$stack');
      return null;
    }
  }

  // For testing: reset all orders
  void clearDummyOrders() {
    _dummyOrders.clear();
  }
}
