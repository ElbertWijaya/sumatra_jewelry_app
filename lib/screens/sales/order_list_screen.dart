// sumatra_jewelry_app/lib/screens/sales/order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart'; // Pastikan Order model diimpor
import 'package:sumatra_jewelry_app/services/order_service.dart'; // Pastikan OrderService diimpor
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Untuk melihat detail pesanan
import 'package:sumatra_jewelry_app/screens/sales/create_order_screen.dart'; // Untuk membuat pesanan baru

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final fetchedOrders = await _orderService.getOrders();
      setState(() {
        // Tampilkan pesanan yang belum selesai atau yang masih perlu perhatian
        // Misalnya, semua kecuali yang COMPLETED atau CANCELED
        _orders =
            fetchedOrders
                .where(
                  (order) =>
                      order.status != OrderStatus.completed &&
                      order.status != OrderStatus.canceled,
                )
                .toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Gagal memuat daftar pesanan: ${e.toString().replaceAll('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan Aktif'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
          );
          if (result == true) {
            _fetchOrders(); // Refresh daftar setelah pesanan baru dibuat
          }
        },
        child: const Icon(Icons.add),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchOrders,
                child:
                    _orders.isEmpty
                        ? const Center(child: Text('Tidak ada pesanan aktif.'))
                        : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 2,
                              child: ListTile(
                                title: Text(
                                  'Pesanan #${order.id} - ${order.customerName}',
                                ),
                                subtitle: Text(
                                  'Produk: ${order.productName}\n'
                                  'Status: ${order.status.toDisplayString()}', // Menggunakan extension toDisplayString()
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () async {
                                  // Asumsikan userRole untuk list ini adalah 'sales'
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => OrderDetailScreen(
                                            order: order,
                                            userRole: 'sales',
                                          ),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchOrders(); // Refresh jika detail diubah
                                  }
                                },
                              ),
                            );
                          },
                        ),
              ),
    );
  }
}
