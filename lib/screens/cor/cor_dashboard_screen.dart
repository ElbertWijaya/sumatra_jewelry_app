import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart';
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart';

class CorDashboardScreen extends StatefulWidget {
  final String userRole;
  const CorDashboardScreen({super.key, required this.userRole});

  @override
  State<CorDashboardScreen> createState() => _CorDashboardScreenState();
}

class _CorDashboardScreenState extends State<CorDashboardScreen> {
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

  List<Order> _getMyActiveCorTasks() {
    return _allOrders.where((order) {
      return order.status == 'ready_for_cor' ||
          order.status == 'cor_in_progress';
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
    final readyForCorCount =
        _allOrders.where((order) => order.status == 'ready_for_cor').length;
    final corInProgressCount =
        _allOrders.where((order) => order.status == 'cor_in_progress').length;
    final corCompletedCount =
        _allOrders.where((order) {
          return order.status == 'cor_completed' ||
              order.status == 'ready_for_carving' ||
              order.status == 'carving_in_progress' ||
              order.status == 'carving_completed' ||
              order.status == 'ready_for_diamond_setting' ||
              order.status == 'diamond_setting_in_progress' ||
              order.status == 'diamond_setting_completed' ||
              order.status == 'ready_for_finishing' ||
              order.status == 'finishing_in_progress' ||
              order.status == 'finishing_completed' ||
              order.status == 'ready_for_pickup';
        }).length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('COR Dashboard'),
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
                      // TAB 1: Tugas Saya (COR) - Aksi Cor HARUS ADA
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ringkasan Tugas COR',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildOrderSummaryCard(
                                      'Siap COR',
                                      readyForCorCount,
                                      Colors.blueAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildOrderSummaryCard(
                                      'Sedang COR',
                                      corInProgressCount,
                                      Colors.orange,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildOrderSummaryCard(
                                      'COR Selesai',
                                      corCompletedCount,
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
                              'Pesanan untuk Saya (${_getMyActiveCorTasks().length})',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Expanded(
                            child:
                                _getMyActiveCorTasks().isEmpty
                                    ? const Center(
                                      child: Text(
                                        'Tidak ada pesanan yang perlu Anda kerjakan saat ini.',
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      itemCount: _getMyActiveCorTasks().length,
                                      itemBuilder: (context, index) {
                                        final order =
                                            _getMyActiveCorTasks()[index];
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
                                                        // TETAPKAN userRole: 'cor' di sini
                                                        // karena ini adalah tugas aktif untuk COR
                                                        userRole:
                                                            widget.userRole,
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

                      // TAB 2: Monitoring (COR) - Aksi Cor HARUS HILANG
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
                                                        // Teruskan userRole yang BUKAN 'cor'
                                                        // sehingga OrderDetailScreen tidak menampilkan Aksi Cor.
                                                        // Misalnya, 'viewer' atau 'sales'
                                                        userRole:
                                                            'viewer', // Atau 'sales', 'monitor', dll.
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
