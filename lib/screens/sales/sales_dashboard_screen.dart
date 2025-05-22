// sumatra_jewelry_app/lib/screens/sales/sales_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/create_order_screen.dart';
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart';
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
  // State untuk search dan filter
  String _searchQuery = '';
  // Ubah tipe menjadi Object? agar bisa menampung OrderStatus atau String 'onProgress'
  Object? _selectedStatusFilter;
  String? _selectedCategoryFilter; // Filter tambahan (Progress, Jenis, Harga)

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

  // Metode untuk memfilter pesanan berdasarkan query pencarian dan filter status
  List<Order> get _filteredOrders {
    List<Order> filtered = _orders;

    // Filter berdasarkan status
    if (_selectedStatusFilter == null) {
      // 'Semua' filter: Tampilkan semua kecuali yang dibatalkan
      filtered = filtered.where((order) => order.status != OrderStatus.canceled).toList();
    } else if (_selectedStatusFilter is OrderStatus) {
      // Filter status spesifik (Waiting/Pending, Submitted/Completed)
      filtered = filtered
          .where((order) => order.status == _selectedStatusFilter)
          .toList();
    } else if (_selectedStatusFilter == 'onProgress') {
      // Filter 'On Progress': Semua yang bukan pending, completed, atau canceled
      filtered = filtered.where((order) =>
          order.status != OrderStatus.pending &&
          order.status != OrderStatus.completed &&
          order.status != OrderStatus.canceled).toList();
    }

    // Filter berdasarkan search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final query = _searchQuery.toLowerCase();
        return order.customerName.toLowerCase().contains(query) ||
               order.productName.toLowerCase().contains(query) ||
               order.status.toDisplayString().toLowerCase().contains(query);
      }).toList();
    }

    // TODO: Implementasi filter kategori tambahan (Progress, Jenis, Harga)
    // if (_selectedCategoryFilter != null) {
    //   // Logika filter sesuai _selectedCategoryFilter
    // }

    return filtered;
  }

  // Helper function untuk membangun status filter button dengan jumlah
  Widget _buildStatusFilterButton(
      String label, Object? filterValue, Color color) { // filterValue bisa OrderStatus atau String 'onProgress'
    int count;
    if (filterValue == null) { // 'Semua'
      count = _orders.where((order) => order.status != OrderStatus.canceled).length;
    } else if (filterValue is OrderStatus) { // Jika satu status
      count = _orders.where((order) => order.status == filterValue).length;
    } else if (filterValue == 'onProgress') { // Jika 'On Progress'
      count = _orders.where((order) =>
          order.status != OrderStatus.pending &&
          order.status != OrderStatus.completed &&
          order.status != OrderStatus.canceled).length;
    } else {
      count = 0; // Kasus lain
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell( // Menggunakan InkWell agar bisa diklik dan ada ripple effect
          onTap: () {
            setState(() {
              _selectedStatusFilter = filterValue;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              // Logika warna berdasarkan _selectedStatusFilter yang cocok dengan filterValue
              color: _selectedStatusFilter == filterValue ? color.withOpacity(0.8) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedStatusFilter == filterValue ? color : Colors.grey,
                width: 1.5
              )
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _selectedStatusFilter == filterValue ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _selectedStatusFilter == filterValue ? Colors.white : color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: _selectedStatusFilter == filterValue ? color : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Dashboard'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateOrderScreen(),
            ),
          );
          if (result == true) {
            _fetchOrders();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pesanan'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
                      // 1. Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Search',
                            hintText: 'Cari nama pelanggan atau produk...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                        ),
                      ),
                      // 2. Status Filter Tabs (Waiting, On Progress, Submitted)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusFilterButton('Semua', null, Colors.deepPurple), // Custom 'All' filter
                            _buildStatusFilterButton('Waiting', OrderStatus.pending, Colors.orange),
                            _buildStatusFilterButton('On Progress', 'onProgress', Colors.blue), // <--- INI PERBAIKANNYA
                            _buildStatusFilterButton('Submitted', OrderStatus.completed, Colors.green),
                          ],
                        ),
                      ),
                      // 3. Categories Filter (Progress, Jenis, Harga)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filter Kategori:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Row(
                              children: [
                                TextButton(onPressed: () {
                                  // TODO: Implementasi filter Progress
                                  setState(() {
                                    _selectedCategoryFilter = 'Progress';
                                  });
                                }, child: Text('Progress', style: TextStyle(color: _selectedCategoryFilter == 'Progress' ? Theme.of(context).primaryColor : Colors.black))),
                                TextButton(onPressed: () {
                                  // TODO: Implementasi filter Jenis
                                  setState(() {
                                    _selectedCategoryFilter = 'Jenis';
                                  });
                                }, child: Text('Jenis', style: TextStyle(color: _selectedCategoryFilter == 'Jenis' ? Theme.of(context).primaryColor : Colors.black))),
                                TextButton(onPressed: () {
                                  // TODO: Implementasi filter Harga
                                  setState(() {
                                    _selectedCategoryFilter = 'Harga';
                                  });
                                }, child: Text('Harga', style: TextStyle(color: _selectedCategoryFilter == 'Harga' ? Theme.of(context).primaryColor : Colors.black))),
                                IconButton(
                                  icon: const Icon(Icons.filter_list),
                                  onPressed: () {
                                    // TODO: Tampilkan dialog/bottom sheet untuk filter lebih lanjut
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Filter lebih lanjut akan ditambahkan!'))
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 4. Product List (Scrollable)
                      Expanded(
                        child: _filteredOrders.isEmpty
                            ? Center(
                                child: Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ada pesanan cocok dengan pencarian Anda.'
                                      : 'Tidak ada pesanan aktif.',
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _filteredOrders[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    child: ListTile(
                                      leading: const CircleAvatar( // Placeholder Gambar
                                        backgroundColor: Colors.blueGrey,
                                        child: Icon(Icons.image, color: Colors.white),
                                      ),
                                      title: Text(
                                        order.customerName, // Nama Penerima
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Produk: ${order.productName}'), // Nama Produk
                                          Text(
                                            'Status: ${order.status.toDisplayString()}',
                                            style: TextStyle(
                                              color: order.status == OrderStatus.pending ? Colors.orange
                                                   : order.status == OrderStatus.completed ? Colors.green
                                                   : order.status == OrderStatus.canceled ? Colors.red
                                                   : Colors.blue, // Warna default untuk status 'in progress' lainnya
                                            ),
                                          ), // Status
                                        ],
                                      ),
                                      trailing: const Icon(Icons.arrow_forward_ios),
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OrderDetailScreen(
                                              order: order,
                                              userRole: 'sales',
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
                ),
    );
  }
}