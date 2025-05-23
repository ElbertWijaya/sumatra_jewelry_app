import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DesignerDashboardScreen extends StatefulWidget {
  const DesignerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DesignerDashboardScreen> createState() =>
      _DesignerDashboardScreenState();
}

class _DesignerDashboardScreenState extends State<DesignerDashboardScreen> {
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
                      o.workflowStatus == OrderWorkflowStatus.pending ||
                      o.workflowStatus == OrderWorkflowStatus.designing,
                )
                .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat pesanan: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final pending =
        _orders
            .where((o) => o.workflowStatus == OrderWorkflowStatus.pending)
            .length;
    final designing =
        _orders
            .where((o) => o.workflowStatus == OrderWorkflowStatus.designing)
            .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Designer')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Menunggu Desain: $pending'),
                    Text('Sedang Didisain: $designing'),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (_, idx) {
                          final order = _orders[idx];
                          return ListTile(
                            title: Text(order.customerName),
                            subtitle: Text(order.jewelryType),
                            trailing: Text(order.workflowStatus.label),
                            onTap:
                                () => Navigator.of(context).pushNamed(
                                  '/designer/detail',
                                  arguments: order,
                                ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
