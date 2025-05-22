// carver_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Pastikan path ini benar
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart';

class CarverDashboardScreen extends StatefulWidget {
  final String userRole;
  const CarverDashboardScreen({super.key, required this.userRole});

  @override
  State<CarverDashboardScreen> createState() => _CarverDashboardScreenState();
}

class _CarverDashboardScreenState extends State<CarverDashboardScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _allOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  static const List<String> _monitoredStatuses = [
    'pending',
    'assigned_to_designer',
    'designing',
    'design_completed',
    'ready_for_cor',
    'cor_in_progress',
    'cor_completed',
    'ready_for_carving',
    'carving_in_progress',
    'carving_completed',
    'ready_for_diamond_setting',
    'diamond_setting_in_progress',
    'diamond_setting_completed',
    'ready_for_finishing',
    'finishing_in_progress',
    'finishing_completed',
    'ready_for_pickup',
  ];

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
        _allOrders = fetchedOrders;
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

  List<Order> _getMyActiveCarverTasks() {
    return _allOrders.where((order) {
      return order.status == 'ready_for_carving' ||
          order.status == 'carving_in_progress';
    }).toList();
  }

  List<Order> _getMonitoredOrders() {
    return _allOrders.where((order) {
      return _monitoredStatuses.contains(order.status);
    }).toList();
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
    final readyForCarvingCount =
        _allOrders.where((order) => order.status == 'ready_for_carving').length;
    final carvingInProgressCount =
        _allOrders
            .where((order) => order.status == 'carving_in_progress')
            .length;
    final carvingCompletedCount =
        _allOrders
            .where(
              (order) =>
                  order.status == 'carving_completed' ||
                  order.status == 'ready_for_diamond_setting' ||
                  order.status == 'diamond_setting_in_progress' ||
                  order.status == 'diamond_setting_completed' ||
                  order.status == 'ready_for_finishing' ||
                  order.status == 'finishing_in_progress' ||
                  order.status == 'finishing_completed' ||
                  order.status == 'ready_for_pickup',
            )
            .length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Carver Dashboard'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchOrders,
            ),
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
          bottom: const TabBar(
            tabs: [Tab(text: 'Tugas Saya'), Tab(text: 'Monitoring')],
          ),
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
                  child: TabBarView(
                    children: [
                      // TAB 1: Tugas Saya (Carver) - Aksi Carver HARUS ADA
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ringkasan Tugas Carver',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildOrderSummaryCard(
                                      'Siap Ukir',
                                      readyForCarvingCount,
                                      Colors.blueAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildOrderSummaryCard(
                                      'Sedang Ukir',
                                      carvingInProgressCount,
                                      Colors.orange,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildOrderSummaryCard(
                                      'Ukir Selesai',
                                      carvingCompletedCount,
                                      Colors.green,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              'Pesanan untuk Saya (${_getMyActiveCarverTasks().length})',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Expanded(
                            child:
                                _getMyActiveCarverTasks().isEmpty
                                    ? const Center(
                                      child: Text(
                                        'Tidak ada pesanan yang perlu Anda kerjakan saat ini.',
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      itemCount:
                                          _getMyActiveCarverTasks().length,
                                      itemBuilder: (context, index) {
                                        final order =
                                            _getMyActiveCarverTasks()[index];
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
                                                      (
                                                        context,
                                                      ) => OrderDetailScreen(
                                                        order: order,
                                                        userRole:
                                                            widget
                                                                .userRole, // <<< Teruskan userRole 'carver'
                                                      ),
                                                ),
                                              );
                                              if (result == true) {
                                                _fetchOrders();
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),

                      // TAB 2: Monitoring (Carver) - Aksi Carver HARUS HILANG
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Monitoring Pesanan (${_getMonitoredOrders().length} dari ${_allOrders.length} Total)',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Expanded(
                            child:
                                _getMonitoredOrders().isEmpty
                                    ? const Center(
                                      child: Text(
                                        'Tidak ada pesanan yang sedang dalam proses produksi.',
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      itemCount: _getMonitoredOrders().length,
                                      itemBuilder: (context, index) {
                                        final order =
                                            _getMonitoredOrders()[index];
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
                                                      (
                                                        context,
                                                      ) => OrderDetailScreen(
                                                        order: order,
                                                        // *** INI PERUBAHAN UTAMA ***
                                                        // Teruskan userRole yang BUKAN 'carver'
                                                        // Agar aksi Carver tidak muncul di OrderDetailScreen
                                                        userRole:
                                                            'viewer', // Contoh: meneruskan peran 'viewer'
                                                      ),
                                                ),
                                              );
                                              if (result == true) {
                                                _fetchOrders();
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
