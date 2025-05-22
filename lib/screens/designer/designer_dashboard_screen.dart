// sumatra_jewelry_app/screens/designer/designer_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Pastikan ini diimpor untuk navigasi ke detail
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart'; // Untuk logout

class DesignerDashboardScreen extends StatefulWidget {
  const DesignerDashboardScreen({super.key});

  @override
  State<DesignerDashboardScreen> createState() =>
      _DesignerDashboardScreenState();
}

class _DesignerDashboardScreenState extends State<DesignerDashboardScreen> {
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
        _orders = fetchedOrders; // Ambil semua order, filter di UI
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
    final pendingOrders =
        _orders
            .where(
              (order) =>
                  order.status == 'pending' ||
                  order.status == 'assigned_to_designer',
            )
            .length;
    final designingOrders =
        _orders.where((order) => order.status == 'designing').length;
    final readyForCorOrders =
        _orders.where((order) => order.status == 'ready_for_cor').length;

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
            .where((order) => inProgressStatuses.contains(order.status)).length;
    // --- AKHIR PERBAIKAN BUG ---

    return Scaffold(
      appBar: AppBar(
        title: const Text('Designer Dashboard'),
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
                            'Ringkasan Pesanan Designer',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildOrderSummaryCard(
                                'Menunggu Desain',
                                pendingOrders,
                                Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              _buildOrderSummaryCard(
                                'Sedang Dikerjakan',
                                designingOrders,
                                Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              _buildOrderSummaryCard(
                                'Siap ke Cor',
                                readyForCorOrders,
                                Colors.purple,
                              ),

                              const SizedBox(width: 10), // Tambahkan SizedBox ini
                              _buildOrderSummaryCard(
                                'Sedang Diproses', // Atau 'Total Proses'
                                processingOrders,
                                Colors.brown, // Warna lain yang sesuai
                              ),
                                
                              // _buildOrderSummaryCard('Total Diproses', processingOrders, Colors.brown),
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
                                  // Hanya tampilkan pesanan yang relevan untuk designer
                                  if ([
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
                                                        'designer', // Teruskan peran 'designer'
                                                  ),
                                            ),
                                          );
                                          if (result == true) {
                                            _fetchOrders(); // Refresh data jika ada perubahan
                                          }
                                        },
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink(); // Sembunyikan jika tidak relevan
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
