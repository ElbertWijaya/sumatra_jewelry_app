import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class CarverDashboardScreen extends StatefulWidget {
  const CarverDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CarverDashboardScreen> createState() => _CarverDashboardScreenState();
}

class _CarverDashboardScreenState extends State<CarverDashboardScreen> {
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
                      o.workflowStatus == OrderWorkflowStatus.readyForCarving ||
                      o.workflowStatus == OrderWorkflowStatus.carving,
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
              (o) => o.workflowStatus == OrderWorkflowStatus.readyForCarving,
            )
            .length;
    final carving =
        _orders
            .where((o) => o.workflowStatus == OrderWorkflowStatus.carving)
            .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Carver')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Menunggu Ukir: $ready'),
                    Text('Sedang Diukir: $carving'),
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
