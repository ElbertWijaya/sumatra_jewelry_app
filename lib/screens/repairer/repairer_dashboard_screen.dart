// sumatra_jewelry_app/screens/repairer/repairer_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Untuk melihat detail pesanan
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart'; // Untuk logout

class RepairerDashboardScreen extends StatefulWidget {
  const RepairerDashboardScreen({super.key});

  @override
  State<RepairerDashboardScreen> createState() =>
      _RepairerDashboardScreenState();
}

class _RepairerDashboardScreenState extends State<RepairerDashboardScreen> {
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
      final fetchedOrders = await _orderService.getActiveOrders();
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
    // Logika perhitungan untuk ringkasan pesanan Repairer
    final pendingRepairOrders =
        _orders.where((order) => order.status == 'pending_repair').length;
    final repairInProgressOrders =
        _orders.where((order) => order.status == 'repair_in_progress').length;
    final completedRepairOrders =
        _orders
            .where(
              (order) =>
                  order.status == 'completed_repair' ||
                  order.status == 'ready_for_pickup',
            )
            .length;

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
      'pending_repair',
      'repair_in_progress',
    ];
    final totalInProgressOrders =
        _orders
            .where((order) => inProgressStatuses.contains(order.status))
            .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repairer Dashboard'),
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
                            'Ringkasan Pesanan Perbaikan',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildOrderSummaryCard(
                                'Menunggu Perbaikan',
                                pendingRepairOrders,
                                Colors.red,
                              ),
                              const SizedBox(width: 10),
                              _buildOrderSummaryCard(
                                'Sedang Dikerjakan',
                                repairInProgressOrders,
                                Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              _buildOrderSummaryCard(
                                'Perbaikan Selesai',
                                completedRepairOrders,
                                Colors.green,
                              ),
                              // Contoh: _buildOrderSummaryCard('Total Diproses', totalInProgressOrders, Colors.purple),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          _orders.isEmpty
                              ? const Center(
                                child: Text('Tidak ada pesanan perbaikan.'),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  // Hanya tampilkan pesanan yang relevan untuk Repairer
                                  if ([
                                    'pending_repair',
                                    'repair_in_progress',
                                    'completed_repair',
                                    'ready_for_pickup',
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
                                          'Status: ${order.status.replaceAll('_', ' ').toUpperCase()}',
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                        ),
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => OrderDetailScreen(
                                                    order: order,
                                                    userRole:
                                                        'repairer', // Teruskan peran
                                                  ),
                                            ),
                                          );
                                          if (result == true) {
                                            _fetchOrders();
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
