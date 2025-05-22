// lib/screens/sales/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Pastikan path ini benar

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _completedOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCompletedOrders();
  }

  Future<void> _fetchCompletedOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final fetchedOrders = await _orderService.getOrders();
      setState(() {
        // Filter pesanan yang dianggap "selesai" atau "diambil pelanggan"
        // Menambahkan 'completed' ke daftar status yang dianggap selesai
        _completedOrders =
            fetchedOrders.where((order) {
              return order.status == 'ready_for_pickup' ||
                  order.status == 'picked_up_by_customer' ||
                  order.status == 'completed'; // <--- PERUBAHAN DI SINI!
            }).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat riwayat pesanan: $e';
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
        title: const Text('Daftar Transaksi Selesai'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCompletedOrders,
          ),
        ],
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
                onRefresh: _fetchCompletedOrders,
                child:
                    _completedOrders.isEmpty
                        ? const Center(
                          child: Text(
                            'Tidak ada riwayat transaksi selesai.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _completedOrders.length,
                          itemBuilder: (context, index) {
                            final order = _completedOrders[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 2,
                              child: ListTile(
                                title: Text(
                                  'Pesanan #${order.id} - ${order.customerName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Produk: ${order.productName}\n'
                                  'Status: ${order.status.replaceAll('_', ' ').toUpperCase()}\n'
                                  'Tanggal Selesai: ${order.finishingCompletionDate != null ? DateFormat('dd/MM/yyyy').format(order.finishingCompletionDate!) : 'N/A'}',
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Saat melihat detail pesanan yang sudah selesai,
                                  // selalu teruskan userRole 'viewer' agar tidak ada tombol aksi
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => OrderDetailScreen(
                                            order: order,
                                            userRole:
                                                'viewer', // Pastikan tidak ada aksi di sini
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
              ),
    );
  }
}
