import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'sales_detail_screen.dart';

/// Displays a chronological list of all orders for historical reference.
class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.getOrders();
      if (!mounted) return;
      // Sort orders by createdAt descending (most recent first)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() => _orders = orders);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order history: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  void _navigateToDetail(String orderId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SalesDetailScreen(orderId: orderId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI design remains unchanged; logic is robust and maintainable
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadOrderHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
              ? const Center(child: Text('No order history found.'))
              : ListView.separated(
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return ListTile(
                    title: Text(order.customerName),
                    subtitle: Text(
                      '${order.status.label} • ${order.createdAt}',
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () => _navigateToDetail(order.id),
                  );
                },
              ),
    );
  }
}
