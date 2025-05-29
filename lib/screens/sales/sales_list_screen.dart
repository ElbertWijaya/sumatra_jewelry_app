import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/screens/sales/sales_detail_screen.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
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
        _orders = orders.where((o) =>
          o.workflowStatus != OrderWorkflowStatus.done &&
          o.workflowStatus != OrderWorkflowStatus.cancelled
        ).toList();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pesanan Sales')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return ListTile(
                  title: Text(order.customerName),
                  subtitle: Text('Status: ${order.workflowStatus.label}'),
                  onTap: () => Navigator.of(context).push(
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