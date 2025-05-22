// sumatra_jewelry_app/lib/screens/inventory/inventory_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart'; // Import Order model
import 'package:sumatra_jewelry_app/services/order_service.dart'; // Import OrderService
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart'; // Untuk melihat detail pesanan
import 'package:sumatra_jewelry_app/screens/inventory/add_product_screen.dart'; // Import AddProductScreen
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart'; // Untuk logout


class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() =>
      _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
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

  Widget _buildSummaryCard(String title, int count, Color color) {
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
    // Inventory mungkin tertarik pada semua pesanan untuk melihat bahan baku atau produk yang dibutuhkan
    // Atau hanya pesanan yang statusnya membutuhkan intervensi inventory (misal: 'pending' untuk verifikasi stok)
    final pendingOrders =
        _orders.where((order) => order.status == OrderStatus.pending).length;
    final inProgressOrders = _orders
        .where((order) =>
            order.status != OrderStatus.pending &&
            order.status != OrderStatus.completed &&
            order.status != OrderStatus.canceled &&
            order.status != OrderStatus.readyForPickup)
        .length;
    final completedOrders =
        _orders.where((order) => order.status == OrderStatus.completed).length;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
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
                              'Ringkasan Inventori Pesanan',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildSummaryCard(
                                  'Pesanan Menunggu',
                                  pendingOrders,
                                  Colors.orange,
                                ),
                                const SizedBox(width: 10),
                                _buildSummaryCard(
                                  'Dalam Proses',
                                  inProgressOrders,
                                  Colors.blue,
                                ),
                                const SizedBox(width: 10),
                                _buildSummaryCard(
                                  'Selesai',
                                  completedOrders,
                                  Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Tombol untuk menambah produk baru
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AddProductScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Tambah Produk Baru'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  backgroundColor: Colors.deepPurple,
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
                        child: _orders.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tidak ada pesanan yang tersedia untuk inventori.',
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  // Inventory mungkin perlu melihat semua pesanan atau yang spesifik
                                  // Untuk contoh ini, kita tampilkan semua pesanan
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
                                              userRole: 'inventory',
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