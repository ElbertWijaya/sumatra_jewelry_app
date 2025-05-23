import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({Key? key}) : super(key: key);

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
        // Tampilkan semua pesanan yang belum selesai/batal
        _orders =
            orders
                .where(
                  (o) =>
                      o.workflowStatus != OrderWorkflowStatus.done &&
                      o.workflowStatus != OrderWorkflowStatus.cancelled,
                )
                .toList();
        _orders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat daftar pesanan: $e')),
      );
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
              ? const Center(child: Text('Belum ada pesanan aktif.'))
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
                                order.workflowStatus ==
                                        OrderWorkflowStatus.pending
                                    ? Colors.orange
                                    : Colors.blueGrey,
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
