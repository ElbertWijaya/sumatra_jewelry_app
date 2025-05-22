// diamond_setter_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Pastikan path ini benar
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart';

class DiamondSetterDashboardScreen extends StatefulWidget {
  final String userRole;
  const DiamondSetterDashboardScreen({super.key, required this.userRole});

  @override
  State<DiamondSetterDashboardScreen> createState() =>
      _DiamondSetterDashboardScreenState();
}

class _DiamondSetterDashboardScreenState
    extends State<DiamondSetterDashboardScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _allOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Daftar status yang akan dimonitor di tab "Monitoring"
  // Ini mencakup semua status yang relevan dari awal hingga akhir proses
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
    _fetchOrders(); // Panggil fungsi untuk mengambil data pesanan saat inisialisasi
  }

  // Fungsi untuk mengambil semua pesanan dari service
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true; // Set loading state menjadi true
      _errorMessage = ''; // Hapus pesan error sebelumnya
    });
    try {
      final fetchedOrders = await _orderService.getOrders(); // Ambil pesanan
      setState(() {
        _allOrders = fetchedOrders; // Perbarui daftar pesanan
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Gagal memuat pesanan: $e'; // Tangani error jika terjadi
      });
    } finally {
      setState(() {
        _isLoading = false; // Set loading state menjadi false setelah selesai
      });
    }
  }

  // Fungsi untuk mendapatkan daftar pesanan yang merupakan tugas aktif Diamond Setter
  // yaitu pesanan yang siap dipasang berlian atau sedang dalam proses pemasangan berlian
  List<Order> _getMyActiveDiamondSetterTasks() {
    return _allOrders.where((order) {
      return order.status == 'ready_for_diamond_setting' ||
          order.status == 'diamond_setting_in_progress';
    }).toList();
  }

  // Fungsi untuk mendapatkan daftar pesanan yang akan ditampilkan di tab "Monitoring"
  // Ini adalah semua pesanan yang statusnya ada di dalam _monitoredStatuses
  List<Order> _getMonitoredOrders() {
    return _allOrders.where((order) {
      return _monitoredStatuses.contains(order.status);
    }).toList();
  }

  // Widget pembantu untuk menampilkan ringkasan jumlah pesanan dalam bentuk kartu
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
    // Menghitung jumlah pesanan untuk ringkasan di dashboard
    final readyForDiamondSettingCount =
        _allOrders
            .where((order) => order.status == 'ready_for_diamond_setting')
            .length;
    final diamondSettingInProgressCount =
        _allOrders
            .where((order) => order.status == 'diamond_setting_in_progress')
            .length;
    // Status completed untuk Diamond Setter bisa berarti sudah selesai dan siap ke tahap selanjutnya
    final diamondSettingCompletedCount =
        _allOrders
            .where(
              (order) =>
                  order.status == 'diamond_setting_completed' ||
                  order.status == 'ready_for_finishing' ||
                  order.status == 'finishing_in_progress' ||
                  order.status == 'finishing_completed' ||
                  order.status == 'ready_for_pickup',
            )
            .length;

    return DefaultTabController(
      length: 2, // Ada 2 tab: "Tugas Saya" dan "Monitoring"
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diamond Setter Dashboard'),
          centerTitle: true,
          actions: [
            // Tombol refresh untuk memuat ulang data pesanan
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchOrders,
            ),
            // Tombol logout untuk kembali ke halaman login
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
          // TabBar di bagian bawah AppBar
          bottom: const TabBar(
            tabs: [Tab(text: 'Tugas Saya'), Tab(text: 'Monitoring')],
          ),
        ),
        body:
            _isLoading // Tampilkan indikator loading jika data sedang dimuat
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage
                    .isNotEmpty // Tampilkan pesan error jika ada
                ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _fetchOrders, // Izinkan pull-to-refresh
                  child: TabBarView(
                    children: [
                      // TAB 1: Tugas Saya (Diamond Setter)
                      // Pesanan di sini harus menampilkan tombol aksi di OrderDetailScreen
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ringkasan Tugas Diamond Setter',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildOrderSummaryCard(
                                      'Siap Pasang Berlian',
                                      readyForDiamondSettingCount,
                                      Colors.blueAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildOrderSummaryCard(
                                      'Sedang Pasang Berlian',
                                      diamondSettingInProgressCount,
                                      Colors.orange,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildOrderSummaryCard(
                                      'Pemasangan Selesai',
                                      diamondSettingCompletedCount,
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
                              'Pesanan untuk Saya (${_getMyActiveDiamondSetterTasks().length})',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Expanded(
                            child:
                                _getMyActiveDiamondSetterTasks().isEmpty
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
                                          _getMyActiveDiamondSetterTasks()
                                              .length,
                                      itemBuilder: (context, index) {
                                        final order =
                                            _getMyActiveDiamondSetterTasks()[index];
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
                                              // Saat membuka detail dari "Tugas Saya", teruskan userRole 'diamond_setter'
                                              // agar tombol aksi diamond setter muncul
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => OrderDetailScreen(
                                                        order: order,
                                                        userRole:
                                                            'diamond_setter',
                                                      ),
                                                ),
                                              );
                                              if (result == true) {
                                                _fetchOrders(); // Muat ulang data setelah kembali dari detail
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),

                      // TAB 2: Monitoring (Diamond Setter)
                      // Pesanan di sini TIDAK boleh menampilkan tombol aksi
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
                                              // Saat membuka detail dari "Monitoring", teruskan userRole 'viewer'
                                              // agar tombol aksi tidak muncul
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => OrderDetailScreen(
                                                        order: order,
                                                        userRole:
                                                            'viewer', // <<< Teruskan userRole 'viewer' untuk menyembunyikan aksi
                                                      ),
                                                ),
                                              );
                                              if (result == true) {
                                                _fetchOrders(); // Muat ulang data setelah kembali dari detail
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
