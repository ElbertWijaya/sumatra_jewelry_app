// sumatra_jewelry_app/lib/screens/sales/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart'; // Pastikan Order model diimpor
import 'package:sumatra_jewelry_app/services/order_service.dart'; // Pastikan OrderService diimpor
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Untuk melihat detail pesanan

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
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
        _orders = fetchedOrders;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Gagal memuat riwayat pesanan: ${e.toString().replaceAll('Exception: ', '')}';
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
        title: const Text('Riwayat Pesanan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: _isLoading
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
                  child: _orders.isEmpty
                      ? const Center(
                          child: Text('Tidak ada riwayat pesanan.'),
                        )
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
                                  'Status: ${order.status.toDisplayString()}\n' // Menggunakan extension toDisplayString()
                                  'Tanggal: ${order.orderDate.toLocal().toString().split(' ')[0]}',
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () async {
                                  // Asumsikan userRole untuk history adalah 'boss' atau 'sales'
                                  // Tergantung siapa yang mengakses history ini.
                                  // Untuk umum, kita bisa pakai 'sales' atau 'boss'
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailScreen(
                                        order: order,
                                        userRole: 'sales', // Atau 'boss'
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