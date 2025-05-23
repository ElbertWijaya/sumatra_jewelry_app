import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
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
        _orders = orders;
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
    final done =
        _orders
            .where((o) => o.workflowStatus == OrderWorkflowStatus.done)
            .length;
    final cancelled =
        _orders
            .where((o) => o.workflowStatus == OrderWorkflowStatus.cancelled)
            .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Sales')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pesanan Baru: $pending'),
                    Text('Sedang Desain: $designing'),
                    Text('Pesanan Selesai: $done'),
                    Text('Pesanan Batal: $cancelled'),
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
                                ).pushNamed('/sales/detail', arguments: order),
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
