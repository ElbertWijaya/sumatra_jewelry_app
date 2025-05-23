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
        _orders =
            orders
                .where(
                  (o) =>
                      o.workflowStatus == OrderWorkflowStatus.readyForCasting ||
                      o.workflowStatus == OrderWorkflowStatus.casting,
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
    final ready =
        _orders
            .where(
              (o) => o.workflowStatus == OrderWorkflowStatus.readyForCasting,
            )
            .length;
    final casting =
        _orders
            .where((o) => o.workflowStatus == OrderWorkflowStatus.casting)
            .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Cor')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Menunggu Cor: $ready'),
                    Text('Sedang Cor: $casting'),
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
                                () => Navigator.of(
                                  context,
                                ).pushNamed('/order/detail', arguments: order),
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
