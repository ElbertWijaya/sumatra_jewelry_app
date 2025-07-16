import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/screens/sales/sales_detail_screen.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
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
        _orders =
            orders
                .where(
                  (o) =>
                      o.ordersWorkflowStatus == OrderWorkflowStatus.done ||
                      o.ordersWorkflowStatus == OrderWorkflowStatus.cancelled,
                )
                .toList();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan Sales')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return ListTile(
                    title: Text(order.ordersCustomerName),
                    subtitle: Text(
                      'Status: ${order.ordersWorkflowStatus.label}',
                    ),
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SalesDetailScreen(order: order),
                          ),
                        ),
                  );
                },
              ),
    );
  }
}
