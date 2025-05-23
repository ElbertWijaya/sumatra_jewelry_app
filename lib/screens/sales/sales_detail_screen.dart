import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesDetailScreen extends StatefulWidget {
  final String orderId;

  const SalesDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  Order? _order;
  bool _isLoading = false;

  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() => _isLoading = true);
    try {
      final order = await _orderService.getOrderById(widget.orderId);
      if (!mounted) return;
      setState(() => _order = order);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load order: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // UI code, no major changes, just refactored for maintainability
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _order == null
              ? const Center(child: Text('Order not found.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Text(
                      'Customer: ${_order!.customerName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${_order!.status.label}'),
                    const SizedBox(height: 8),
                    Text('Created: ${_order!.createdAt}'),
                    if (_order!.notes != null && _order!.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Notes: ${_order!.notes!}'),
                      ),
                    const Divider(height: 32),
                    const Text('Items:'),
                    ..._order!.items.map(
                      (item) => ListTile(
                        title: Text('${item.productName} x${item.quantity}'),
                        subtitle: Text(
                          '\u20B9${(item.price * item.quantity).toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
