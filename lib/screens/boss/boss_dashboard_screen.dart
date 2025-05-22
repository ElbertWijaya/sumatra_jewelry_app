// sumatra_jewelry_app/screens/boss/boss_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Untuk melihat detail pesanan
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart'; // Untuk logout

class BossDashboardScreen extends StatefulWidget {
  const BossDashboardScreen({super.key});

  @override
  State<BossDashboardScreen> createState() => _BossDashboardScreenState();
}

class _BossDashboardScreenState extends State<BossDashboardScreen> {
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
        _errorMessage = 'Gagal memuat pesanan: $e';
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
    // Logika perhitungan untuk ringkasan pesanan
    final totalOrders = _orders.length;
    final completedOrders =
        _orders.where((order) => order.status == 'completed').length;

    // --- PERBAIKAN BUG INI ---
    // Daftar status yang dianggap "sedang diproses" di seluruh alur kerja
    const inProgressStatuses = [
      'pending',
      'assigned_to_designer',
      'designing',
      'ready_for_cor',
      'cor_in_progress',
      'ready_for_carving',
      'carving_in_progress',
      'ready_for_diamond_setting',
      'diamond_setting_in_progress',
      'ready_for_finishing',
      'finishing_in_progress',
      'ready_for_pickup',
    ];
    final processingOrders =
        _orders
            .where((order) => inProgressStatuses.contains(order.status))
            .length;
    // --- AKHIR PERBAIKAN BUG ---

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boss Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
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
                            'Ringkasan Pesanan Global',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildOrderSummaryCard(
                                'Total Pesanan',
                                totalOrders,
                                Colors.deepPurple,
                              ),
                              const SizedBox(width: 10),
                              _buildOrderSummaryCard(
                                'Pesanan Selesai',
                                completedOrders,
                                Colors.green,
                              ),
                              const SizedBox(width: 10),
                              // Menggunakan `processingOrders` yang sudah diperbaiki
                              _buildOrderSummaryCard(
                                'Sedang Diproses',
                                processingOrders,
                                Colors.orange,
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
                                child: Text('Tidak ada pesanan yang tersedia.'),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
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
                                        'Status: ${order.status.replaceAll('_', ' ').toUpperCase()}\n'
                                        'Penanggung Jawab: ${order.currentWorkerRole ?? 'N/A'}',
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                      ),
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => OrderDetailScreen(
                                                  order: order,
                                                  userRole:
                                                      'boss', // Teruskan peran 'boss'
                                                ),
                                          ),
                                        );
                                        if (result == true) {
                                          _fetchOrders(); // Refresh data jika ada perubahan
                                        }
                                      },
                                    ),
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
