// sumatra_jewelry_app/screens/finisher/finisher_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart'; // Pastikan ini diimpor
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Untuk melihat detail pesanan
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart'; // Untuk logout

class FinisherDashboardScreen extends StatefulWidget {
  const FinisherDashboardScreen({super.key});

  @override
  State<FinisherDashboardScreen> createState() =>
      _FinisherDashboardScreenState();
}

class _FinisherDashboardScreenState extends State<FinisherDashboardScreen> {
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
            'Gagal memuat pesanan: ${e.toString().replaceAll('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildOrderSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logika perhitungan untuk ringkasan pesanan menggunakan enum
    final readyForFinishingOrders =
        _orders
            .where((order) => order.status == OrderStatus.readyForFinishing)
            .length;
    final finishingInProgressOrders =
        _orders
            .where((order) => order.status == OrderStatus.finishingInProgress)
            .length;
    final readyForPickupOrders =
        _orders
            .where((order) => order.status == OrderStatus.readyForPickup)
            .length;

    // Hapus variabel processingOrders yang tidak digunakan
    // const inProgressStatuses = [...];
    // final processingOrders = _orders.where((order) => inProgressStatuses.contains(order.status)).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finisher Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Contoh logout, sesuaikan dengan AuthService Anda
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
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
                onRefresh: _fetchOrders,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ringkasan Pesanan Finisher',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildOrderSummaryCard(
                                'Siap Finishing',
                                readyForFinishingOrders,
                                Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              _buildOrderSummaryCard(
                                'Sedang Finishing',
                                finishingInProgressOrders,
                                Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              _buildOrderSummaryCard(
                                'Siap Diambil',
                                readyForPickupOrders,
                                Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          _orders.isEmpty
                              ? const Center(
                                child: Text(
                                  'Tidak ada pesanan yang tersedia untuk Anda.',
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  // Hanya tampilkan pesanan yang relevan untuk Finisher
                                  if ([
                                    OrderStatus.readyForFinishing,
                                    OrderStatus.finishingInProgress,
                                    OrderStatus.readyForPickup,
                                  ].contains(order.status)) {
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                        title: Text(
                                          'Pesanan #${order.id} - ${order.customerName}',
                                        ),
                                        // Gunakan extension untuk menampilkan status
                                        subtitle: Text(
                                          'Produk: ${order.productName}\n'
                                          'Status: ${order.status.toDisplayString()}',
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                        ),
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      OrderDetailScreen(
                                                        order: order,
                                                        userRole: 'finisher',
                                                      ),
                                            ),
                                          );
                                          if (result == true) {
                                            _fetchOrders(); // Refresh jika ada perubahan
                                          }
                                        },
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
