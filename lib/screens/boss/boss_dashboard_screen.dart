import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class BossDashboardScreen extends StatefulWidget {
  const BossDashboardScreen({Key? key}) : super(key: key);

  @override
  State<BossDashboardScreen> createState() => _BossDashboardScreenState();
}

class _BossDashboardScreenState extends State<BossDashboardScreen> {
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

  int countStatus(OrderWorkflowStatus status) =>
      _orders.where((o) => o.workflowStatus == status).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Boss'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Pesanan Selesai: ${countStatus(OrderWorkflowStatus.done)}',
                  ),
                  Text(
                    'Pesanan Batal: ${countStatus(OrderWorkflowStatus.cancelled)}',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Semua Pesanan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._orders
                      .map(
                        (order) => Card(
                          child: ListTile(
                            title: Text(order.customerName),
                            subtitle: Text(
                              '${order.jewelryType} • ${order.workflowStatus.label}',
                            ),
                            trailing: Text(
                              order.createdAt
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                            ),
                            onTap:
                                () => Navigator.of(
                                  context,
                                ).pushNamed('/order/detail', arguments: order),
                          ),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed('/boss/employee-performance');
                    },
                    child: const Text('Lihat Performa Karyawan'),
                  ),
                ],
              ),
    );
  }
}
