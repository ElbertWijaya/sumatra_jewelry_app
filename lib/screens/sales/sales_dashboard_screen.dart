import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/create_order_screen.dart'; // Untuk membuat pesanan baru
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Untuk melihat detail pesanan
import 'package:sumatra_jewelry_app/screens/sales/order_history_screen.dart';
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart'; // Untuk logout

class SalesDashboardScreen extends StatefulWidget {
  // Sales Dashboard tidak menerima userRole secara eksplisit seperti Designer,
  // karena perannya sudah jelas "sales". Namun, jika di masa depan Sales perlu userRole
  // untuk filter pesanan spesifik sales tertentu, bisa ditambahkan.
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _allOrders = []; // Menyimpan semua pesanan dari service
  bool _isLoading = true;
  String _errorMessage = '';

  // Daftar status yang dianggap "sedang diproses" di seluruh alur kerja untuk monitoring Sales
  static const List<String> _inProgressStatuses = [
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

  // Fungsi untuk memfilter pesanan yang merupakan "Tugas Aktif" Sales
  // Sales secara default melihat semua pesanan yang 'pending' atau yang dia tangani
  List<Order> _getMySalesTasks() {
    return _allOrders.where((order) {
      // Jika Anda punya properti 'salesAssignedTo' di Order model, bisa gunakan itu
      // return order.status == 'pending' || order.salesAssignedTo == 'nama_sales_saat_ini';
      // Untuk demo, kita asumsikan Sales melihat semua 'pending' dan 'ready_for_pickup'
      // Serta mungkin pesanan yang statusnya 'completed' untuk laporan.
      return order.status == 'pending' ||
          order.status == 'ready_for_pickup' ||
          order.status == 'completed';
    }).toList();
  }

  // Fungsi untuk memfilter pesanan yang "Dimonitor" oleh Sales (semua yang sedang dalam proses)
  List<Order> _getMonitoredOrders() {
    return _allOrders
        .where((order) => _inProgressStatuses.contains(order.status))
        .toList();
  }

  // Widget helper untuk kartu ringkasan
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
    // Logika perhitungan untuk ringkasan pesanan Sales
    final newOrders =
        _allOrders.where((order) => order.status == 'pending').length;
    final completedOrders =
        _allOrders.where((order) => order.status == 'completed').length;
    final processingOrders =
        _getMonitoredOrders().length; // Menggunakan fungsi monitoring

    return DefaultTabController(
      length: 2, // Dua tab: "Tugas Saya" dan "Monitoring"
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sales Dashboard'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.history), // Icon yang sesuai
              tooltip:
                  'Daftar Transaksi Selesai', // Muncul saat tombol ditekan lama
              onPressed: () {
                // Ini adalah kode navigasi ke OrderHistoryScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderHistoryScreen(),
                  ),
                );
              },
            ),
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
                      // TAB 1: Tampilan "Tugas Saya" untuk Sales
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ringkasan Pesanan Sales',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildOrderSummaryCard(
                                      'Pesanan Baru',
                                      newOrders,
                                      Colors.blueAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildOrderSummaryCard(
                                      'Sedang Diproses',
                                      processingOrders,
                                      Colors.orange,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildOrderSummaryCard(
                                      'Pesanan Selesai',
                                      completedOrders,
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
                              'Pesanan untuk Saya (${_getMySalesTasks().length})',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Expanded(
                            child:
                                _getMySalesTasks().isEmpty
                                    ? const Center(
                                      child: Text(
                                        'Tidak ada pesanan yang perlu Anda tangani saat ini.',
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      itemCount: _getMySalesTasks().length,
                                      itemBuilder: (context, index) {
                                        final order = _getMySalesTasks()[index];
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
                                                            'sales', // Tetap teruskan 'sales'
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

                      // TAB 2: Tampilan "Monitoring" untuk Sales
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Semua Pesanan yang Diproses (${_getMonitoredOrders().length} dari ${_allOrders.length} Total)',
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
                                                        userRole:
                                                            'monitor', // Tetap teruskan 'sales'
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateOrderScreen(),
              ),
            );
            if (result == true) {
              _fetchOrders(); // Refresh daftar pesanan setelah pesanan baru dibuat
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
