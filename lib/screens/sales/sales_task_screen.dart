import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesTaskScreen extends StatefulWidget {
  const SalesTaskScreen({Key? key}) : super(key: key);

  @override
  State<SalesTaskScreen> createState() => _SalesTaskScreenState();
}

class _SalesTaskScreenState extends State<SalesTaskScreen> {
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
        // Sales melihat order yang statusnya masih awal (belum selesai atau belum dibatalkan)
        _orders =
            orders
                .where(
                  (o) =>
                      o.workflowStatus == OrderWorkflowStatus.pending ||
                      o.workflowStatus == OrderWorkflowStatus.done ||
                      o.workflowStatus == OrderWorkflowStatus.cancelled,
                )
                .toList();
        // Urutkan agar pending di atas
        _orders.sort(
          (a, b) => a.workflowStatus.index.compareTo(b.workflowStatus.index),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat pesanan: $e')));
    }
    setState(() => _isLoading = false);
  }

  void _goToDetail(Order order) {
    Navigator.of(context).pushNamed('/sales/detail', arguments: order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
              ? const Center(child: Text('Belum ada pesanan.'))
              : RefreshIndicator(
                onRefresh: _fetchOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, idx) {
                    final order = _orders[idx];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 0,
                      ),
                      child: ListTile(
                        title: Text(order.customerName),
                        subtitle: Text(
                          '${order.jewelryType} • ${order.customerContact}\n${order.address}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          order.workflowStatus.label,
                          style: TextStyle(
                            color:
                                order.workflowStatus == OrderWorkflowStatus.done
                                    ? Colors.green
                                    : order.workflowStatus ==
                                        OrderWorkflowStatus.cancelled
                                    ? Colors.red
                                    : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _goToDetail(order),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
