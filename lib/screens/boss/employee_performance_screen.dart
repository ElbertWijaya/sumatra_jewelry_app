// sumatra_jewelry_app/lib/screens/boss/employee_performance_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart'; // Import Order model
import 'package:sumatra_jewelry_app/services/order_service.dart'; // Import OrderService

class EmployeePerformanceScreen extends StatefulWidget {
  const EmployeePerformanceScreen({super.key});

  @override
  State<EmployeePerformanceScreen> createState() =>
      _EmployeePerformanceScreenState();
}

class _EmployeePerformanceScreenState extends State<EmployeePerformanceScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _allOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // Untuk performa karyawan, kita mungkin perlu semua pesanan
      // Lalu kita akan memfilter/mengelompokkan berdasarkan assignedTo
      _allOrders = await _orderService.getOrders();
      // TODO: Logika untuk menghitung performa karyawan dari _allOrders
      // Ini akan melibatkan pengelompokan pesanan berdasarkan 'assignedTo'
      // dan menghitung metrik seperti jumlah pesanan selesai, waktu rata-rata, dll.
    } catch (e) {
      setState(() {
        _errorMessage =
            'Gagal memuat data performa: ${e.toString().replaceAll('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kinerja Karyawan'), centerTitle: true),
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
                onRefresh: _fetchData,
                child:
                    _allOrders.isEmpty
                        ? const Center(
                          child: Text(
                            'Tidak ada data pesanan untuk dianalisis performa.',
                          ),
                        )
                        : ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            // Contoh tampilan placeholder untuk performa
                            // Anda akan mengganti ini dengan statistik sebenarnya
                            Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ringkasan Performa (Placeholder)',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Jumlah Total Pesanan: ${_allOrders.length}',
                                    ),
                                    Text(
                                      'Pesanan Selesai: ${_allOrders.where((o) => o.status == OrderStatus.completed).length}',
                                    ),
                                    Text(
                                      'Perlu implementasi logika performa aktual.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Anda bisa menambahkan daftar karyawan dan metrik mereka di sini
                            // Misalnya: ListView.builder untuk daftar karyawan
                            // Dengan ListTile yang menampilkan nama dan metrik kunci
                            Text(
                              'Daftar Pesanan (Untuk Analisis Detail):',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            ..._allOrders.map((order) {
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: ListTile(
                                  title: Text(
                                    '${order.productName} oleh ${order.customerName}',
                                  ),
                                  subtitle: Text(
                                    'Status: ${order.status.toDisplayString()} (${order.assignedTo ?? 'Belum Ditugaskan'})',
                                  ),
                                  // Anda bisa menambahkan onTap untuk melihat detail pesanan jika perlu
                                  // onTap: () {
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) => OrderDetailScreen(
                                  //         order: order,
                                  //         userRole: 'boss', // Boss melihat detail
                                  //       ),
                                  //     ),
                                  //   );
                                  // },
                                ),
                              );
                            }),
                          ],
                        ),
              ),
    );
  }
}
