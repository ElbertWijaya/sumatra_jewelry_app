import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'sales_detail_screen.dart';
import 'sales_create_screen.dart';
import 'sales_edit_screen.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({Key? key}) : super(key: key);

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.getOrders();
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _navigateToCreate() async {
    final created = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SalesCreateScreen()));
    if (created == true) _fetchOrders();
  }

  Future<void> _navigateToEdit(String orderId) async {
    final edited = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SalesEditScreen(orderId: orderId)),
    );
    if (edited == true) _fetchOrders();
  }

  void _navigateToDetail(String orderId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SalesDetailScreen(orderId: orderId)),
    );
  }

  Future<void> _deleteOrder(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Order'),
            content: const Text('Are you sure you want to delete this order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _orderService.deleteOrder(orderId);
      _fetchOrders();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order deleted.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete order: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // UI code, no major changes, just maintainable logic
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchOrders,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
              ? const Center(child: Text('No orders found.'))
              : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return ListTile(
                    title: Text(order.customerName),
                    subtitle: Text(
                      '${order.status.label} • ${order.createdAt}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () => _navigateToDetail(order.id),
                          tooltip: 'View',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToEdit(order.id),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed:
                              _isLoading ? null : () => _deleteOrder(order.id),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: const Icon(Icons.add),
        tooltip: 'Create Order',
      ),
    );
  }
}
