import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class CorDashboardScreen extends StatefulWidget {
  const CorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CorDashboardScreen> createState() => _CorDashboardScreenState();
}

class _CorDashboardScreenState extends State<CorDashboardScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.getOrders();
      setState(() {
        _orders = orders.where((o) => o.currentRole == 'cor').toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('COR Dashboard')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return ListTile(
                      title: Text(order.customerName),
                      subtitle: Text('From Designer • ${order.createdAt}'),
                      // Add navigation or actions as required for COR
                    );
                  },
                ),
              ),
    );
  }
}
