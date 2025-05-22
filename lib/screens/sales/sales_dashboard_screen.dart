// sumatra_jewelry_app/lib/screens/sales/sales_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:sumatra_jewelry_app/screens/sales/create_order_screen.dart';
import 'package:sumatra_jewelry_app/screens/sales/order_detail_screen.dart';
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart';

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
  String _searchQuery = '';
  Object? _selectedStatusFilter;
  String? _selectedCategoryFilter;

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

  List<Order> get _filteredOrders {
    List<Order> filtered = _orders;

    if (_selectedStatusFilter == null) {
      filtered = filtered.where((order) => order.status != OrderStatus.canceled).toList();
    } else if (_selectedStatusFilter is OrderStatus) {
      filtered = filtered
          .where((order) => order.status == _selectedStatusFilter)
          .toList();
    } else if (_selectedStatusFilter == 'onProgress') {
      filtered = filtered.where((order) =>
          order.status != OrderStatus.pending &&
          order.status != OrderStatus.completed &&
          order.status != OrderStatus.canceled).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final query = _searchQuery.toLowerCase();
        return order.customerName.toLowerCase().contains(query) ||
               order.productName.toLowerCase().contains(query) ||
               order.status.toDisplayString().toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Widget _buildStatusFilterButton(
      String label, Object? filterValue, Color color) {
    int count;
    if (filterValue == null) {
      count = _orders.where((order) => order.status != OrderStatus.canceled).length;
    } else if (filterValue is OrderStatus) {
      count = _orders.where((order) => order.status == filterValue).length;
    } else if (filterValue == 'onProgress') {
      count = _orders.where((order) =>
          order.status != OrderStatus.pending &&
          order.status != OrderStatus.completed &&
          order.status != OrderStatus.canceled).length;
    } else {
      count = 0;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedStatusFilter = filterValue;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
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
        backgroundColor: Colors.transparent, // Membuat AppBar transparan
        elevation: 0, // Menghilangkan shadow AppBar
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
      extendBodyBehindAppBar: true, // Memungkinkan body untuk meluas di belakang AppBar
      resizeToAvoidBottomInset: false, // Menghindari perubahan ukuran saat keyboard muncul
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
      body: Stack( // Menggunakan Stack untuk latar belakang
        children: [
          // Latar Belakang Gambar
          Positioned.fill(
            child: Image.asset(
              'assets/images/toko_sumatra.jpg', // Ganti dengan path gambar Anda
              fit: BoxFit.cover, // Sesuaikan dengan kebutuhan: cover, fill, contain
              colorBlendMode: BlendMode.darken, // Opsi untuk membuat gambar sedikit gelap
              color: Colors.black.withOpacity(0.3), // Tingkat kegelapan
            ),
          ),
          // Konten Dashboard
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white,)) // Ubah warna loading indicator
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
                          // Memberi jarak dari AppBar
                          SizedBox(height: AppBar().preferredSize.height + MediaQuery.of(context).padding.top),
                          // 1. Search Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Search',
                                hintText: 'Cari nama pelanggan atau produk...',
                                prefixIcon: const Icon(Icons.search, color: Colors.white70), // Ubah warna ikon
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2), // Latar belakang search bar transparan
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                labelStyle: const TextStyle(color: Colors.white70),
                                hintStyle: const TextStyle(color: Colors.white54),
                                floatingLabelStyle: const TextStyle(color: Colors.white),
                              ),
                              style: const TextStyle(color: Colors.white), // Warna teks input
                            ),
                          ),
                          // --- Penambahan SizedBox untuk spasi ---
                          const SizedBox(height: 150.0), // Jarak antara search bar dan filter status
                          // 2. Status Filter Tabs (Semua, Waiting, On Progress, Submitted)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatusFilterButton('Semua', null, Colors.deepPurple),
                                _buildStatusFilterButton('Waiting', OrderStatus.pending, Colors.orange),
                                _buildStatusFilterButton('On Progress', 'onProgress', Colors.blue),
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
                                // --- MENGHAPUS TEKS "Filter Kategori:" ---
                                // Text(
                                //   'Filter Kategori:',
                                //   style: Theme.of(context).textTheme.titleSmall,
                                // ),
                                Row(
                                  children: [
                                    TextButton(onPressed: () {
                                      setState(() {
                                        _selectedCategoryFilter = 'Progress';
                                      });
                                    }, child: Text('Progress', style: TextStyle(color: _selectedCategoryFilter == 'Progress' ? Colors.white : Colors.white70))), // Warna teks filter kategori
                                    TextButton(onPressed: () {
                                      setState(() {
                                        _selectedCategoryFilter = 'Jenis';
                                      });
                                    }, child: Text('Jenis', style: TextStyle(color: _selectedCategoryFilter == 'Jenis' ? Colors.white : Colors.white70))),
                                    TextButton(onPressed: () {
                                      setState(() {
                                        _selectedCategoryFilter = 'Harga';
                                      });
                                    }, child: Text('Harga', style: TextStyle(color: _selectedCategoryFilter == 'Harga' ? Colors.white : Colors.white70))),
                                    IconButton(
                                      icon: const Icon(Icons.filter_list, color: Colors.white70), // Warna ikon filter
                                      onPressed: () {
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
                                      style: const TextStyle(color: Colors.white70), // Warna teks kosong
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    itemCount: _filteredOrders.length,
                                    itemBuilder: (context, index) {
                                      final order = _filteredOrders[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                                        elevation: 4, // Tingkatkan elevation untuk efek kedalaman
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        color: Colors.white.withOpacity(0.9), // Latar belakang kartu transparan
                                        child: ListTile(
                                          leading: const CircleAvatar(
                                            backgroundColor: Colors.blueGrey,
                                            child: Icon(Icons.image, color: Colors.white),
                                          ),
                                          title: Text(
                                            order.customerName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Produk: ${order.productName}'),
                                              Text(
                                                'Status: ${order.status.toDisplayString()}',
                                                style: TextStyle(
                                                  color: order.status == OrderStatus.pending ? Colors.orange
                                                       : order.status == OrderStatus.completed ? Colors.green
                                                       : order.status == OrderStatus.canceled ? Colors.red
                                                       : Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
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
        ],
      ),
    );
  }
}