// sumatra_jewelry_app/lib/screens/carver/carver_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart'; // Import Order model
import 'package:sumatra_jewelry_app/services/order_service.dart'; // Import OrderService
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Untuk melihat detail pesanan
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart'; // Untuk logout

class CarverDashboardScreen extends StatefulWidget {
  const CarverDashboardScreen({super.key});

  @override
  State<CarverDashboardScreen> createState() => _CarverDashboardScreenState();
}

class _CarverDashboardScreenState extends State<CarverDashboardScreen> {
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
    final readyForCarvingOrders =
        _orders
            .where((order) => order.status == OrderStatus.readyForCarving)
            .length;
    final carvingInProgressOrders =
        _orders
            .where((order) => order.status == OrderStatus.carvingInProgress)
            .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carver Dashboard'),
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
                            'Ringkasan Pesanan Carver',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildOrderSummaryCard(
                                'Siap Carving',
                                readyForCarvingOrders,
                                Colors.brown,
                              ),
                              const SizedBox(width: 10),
                              _buildOrderSummaryCard(
                                'Sedang Carving',
                                carvingInProgressOrders,
                                Colors.blue,
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
                                  // Hanya tampilkan pesanan yang relevan untuk Carver
                                  if ([
                                    OrderStatus.readyForCarving,
                                    OrderStatus.carvingInProgress,
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
                                                        userRole: 'carver',
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
                                  return const SizedBox.shrink(); // Sembunyikan yang tidak relevan
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
