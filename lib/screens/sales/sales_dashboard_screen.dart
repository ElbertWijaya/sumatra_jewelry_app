// sumatra_jewelry_app/lib/screens/sales/sales_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart'; // Import Order model
import 'package:sumatra_jewelry_app/services/order_service.dart'; // Import OrderService
import 'package:sumatra_jewelry_app/screens/sales/create_order_screen.dart'; // Import CreateOrderScreen
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Untuk melihat detail pesanan
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart'; // Untuk logout

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
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
    final pendingOrders =
        _orders.where((order) => order.status == OrderStatus.pending).length;
    final readyForPickupOrders = _orders
        .where((order) => order.status == OrderStatus.readyForPickup)
        .length;
    final completedOrders =
        _orders.where((order) => order.status == OrderStatus.completed).length;

    // Filter pesanan yang relevan untuk sales: semua kecuali yang dibatalkan
    final salesRelevantOrders = _orders
        .where((order) => order.status != OrderStatus.canceled)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Dashboard'),
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
      body: _isLoading
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
                              'Ringkasan Pesanan Sales',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildOrderSummaryCard(
                                  'Pesanan Baru/Pending',
                                  pendingOrders,
                                  Colors.orange,
                                ),
                                const SizedBox(width: 10),
                                _buildOrderSummaryCard(
                                  'Siap Diambil',
                                  readyForPickupOrders,
                                  Colors.lightGreen,
                                ),
                                const SizedBox(width: 10),
                                _buildOrderSummaryCard(
                                  'Selesai',
                                  completedOrders,
                                  Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Navigasi ke CreateOrderScreen
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateOrderScreen(),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchOrders(); // Refresh daftar pesanan setelah pesanan baru dibuat
                                  }
                                },
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Buat Pesanan Baru'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: salesRelevantOrders.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tidak ada pesanan yang tersedia untuk Anda.',
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                itemCount: salesRelevantOrders.length,
                                itemBuilder: (context, index) {
                                  final order = salesRelevantOrders[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                                            builder: (context) =>
                                                OrderDetailScreen(
                                              order: order,
                                              userRole: 'sales', // Lewatkan peran 'sales'
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _fetchOrders(); // Refresh jika ada perubahan
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