// sumatra_jewelry_app/lib/screens/sales/sales_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart'; // Pastikan file order.dart ada dan benar
import 'package:sumatra_jewelry_app/services/order_service.dart'; // Pastikan file order_service.dart ada dan benar
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
      // --- Data Dummy Langsung untuk memastikan ada konten ---
      final fetchedOrders = [
        Order(
          id: '1',
          customerName: 'Budi Santoso',
          productName: 'Kalung Emas',
          status: OrderStatus.pending, // Status ini akan muncul di "Waiting"
          orderDate: DateTime(2023, 10, 26),
          lastUpdated: DateTime(2023, 10, 26, 10, 0),
          totalPrice: 15000000,
          notes: 'Customer ingin ukiran inisial B.S.',
        ),
        Order(
          id: '2',
          customerName: 'Siti Aminah',
          productName: 'Cincin Berlian',
          status: OrderStatus.assignedToDesigner, // Ini akan masuk 'On Progress'
          orderDate: DateTime(2023, 10, 25),
          lastUpdated: DateTime(2023, 10, 26, 11, 30),
          totalPrice: 25000000,
          notes: 'Desain modern, tanpa sudut tajam.',
        ),
        Order(
          id: '3',
          customerName: 'Agus Wijaya',
          productName: 'Gelang Perak',
          status: OrderStatus.completed, // Status ini akan muncul di "Submitted"
          orderDate: DateTime(2023, 10, 24),
          lastUpdated: DateTime(2023, 10, 25, 14, 0),
          totalPrice: 5000000,
          notes: 'Sudah diambil oleh customer.',
        ),
        Order(
          id: '4',
          customerName: 'Dewi Lestari',
          productName: 'Anting Mutiara',
          status: OrderStatus.assignedToCarver, // Ini juga 'On Progress'
          orderDate: DateTime(2023, 10, 23),
          lastUpdated: DateTime(2023, 10, 26, 9, 0),
          totalPrice: 12000000,
          notes: 'Mutiara air tawar besar.',
        ),
        Order(
          id: '5',
          customerName: 'Rini Susanti',
          productName: 'Liontin Nama',
          status: OrderStatus.canceled, // Contoh pesanan dibatalkan (tidak muncul di filter 'Semua' atau 'On Progress')
          orderDate: DateTime(2023, 10, 22),
          lastUpdated: DateTime(2023, 10, 23, 16, 0),
          totalPrice: 7000000,
          notes: 'Customer membatalkan karena harga.',
        ),
        Order(
          id: '6',
          customerName: 'Joko Prabowo',
          productName: 'Giwang Emas',
          status: OrderStatus.designed, // Contoh status 'designed' (akan masuk 'On Progress')
          orderDate: DateTime(2023, 10, 20),
          lastUpdated: DateTime(2023, 10, 26, 13, 0),
          totalPrice: 18000000,
          notes: 'Desain minimalis.',
        ),
         Order(
          id: '7',
          customerName: 'Maria Ulfa',
          productName: 'Kalung Salib',
          status: OrderStatus.processing, // Contoh status 'processing' (akan masuk 'On Progress')
          orderDate: DateTime(2023, 10, 19),
          lastUpdated: DateTime(2023, 10, 26, 15, 0),
          totalPrice: 9000000,
          notes: 'Ukuran kecil.',
        ),
         Order(
          id: '8',
          customerName: 'Kevin Sanjaya',
          productName: 'Bros Custom',
          status: OrderStatus.qualityCheck, // Contoh status 'qualityCheck' (akan masuk 'On Progress')
          orderDate: DateTime(2023, 10, 18),
          lastUpdated: DateTime(2023, 10, 26, 16, 0),
          totalPrice: 11000000,
          notes: 'Bros bentuk inisial.',
        ),
      ];

      // Anda bisa mengganti ini dengan panggilan service nyata nanti:
      // final fetchedOrders = await _orderService.getOrders();

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
      String label, Object? filterValue, Color color) {
    int count;
    if (filterValue == null) { // 'Semua'
      count = _orders.where((order) => order.status != OrderStatus.canceled).length;
    } else if (filterValue is OrderStatus) { // Jika satu status
      count = _orders.where((order) => order.status == filterValue).length;
    } else if (filterValue == 'onProgress') { // Logika hitung jumlah untuk 'On Progress'
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
        backgroundColor: Colors.transparent, // Membuat AppBar transparan
        elevation: 0, // Menghilangkan shadow AppBar
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Pastikan Logout mengarah ke LoginScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true, // Memungkinkan body untuk meluas di belakang AppBar
      resizeToAvoidBottomInset: false, // Penting! Agar background tidak resize saat keyboard muncul
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateOrderScreen(),
            ),
          );
          if (result == true) {
            _fetchOrders(); // Refresh data setelah membuat pesanan baru
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pesanan'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack( // Menggunakan Stack untuk latar belakang
        children: [
          // Latar Belakang Gambar (akan mengisi seluruh Stack dan tidak terpengaruh keyboard)
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg', // Ganti dengan path gambar Anda
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken, // Opsi untuk membuat gambar sedikit gelap
              color: Colors.black.withOpacity(0.3), // Tingkat kegelapan
            ),
          ),
          // Konten Dashboard (akan tetap scrollable di dalamnya jika diperlukan)
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
                      // Bungkus konten yang bisa di-scroll dengan SingleChildScrollView
                      // agar keyboard tidak menutupi TextField jika konten terlalu panjang
                      child: SingleChildScrollView( // Tambahkan ini
                        physics: const AlwaysScrollableScrollPhysics(), // Pastikan bisa di-scroll bahkan jika kontennya tidak penuh
                        child: Column(
                          children: [
                            // 1. Spasi di bawah AppBar untuk menghindari tumpang tindih dengan gambar
                            SizedBox(height: AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 20),

                            // 2. Search Bar
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
                                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
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

                            // 3. SIZEDBOX PENGONTROL JARAK ANTARA SEARCH BAR DAN FILTER STATUS
                            const SizedBox(height: 100.0), // Sesuaikan nilai height di sini

                            // 4. Status Filter Tabs (Semua, Waiting, On Progress, Submitted)
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

                            // 5. Categories Filter (Progress, Jenis, Harga) - Sekarang bisa di-scroll
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row( // <-- Row utama untuk filter kategori
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded( // Expanded agar SingleChildScrollView mengambil sisa ruang
                                    child: SingleChildScrollView( // Membuat kategori bisa di-scroll horizontal
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.zero,
                                      child: Row( // Row untuk menampung tombol-tombol kategori
                                        children: [
                                          TextButton(onPressed: () {
                                            setState(() {
                                              _selectedCategoryFilter = 'Progress';
                                            });
                                          }, child: Text('Progress', style: TextStyle(color: _selectedCategoryFilter == 'Progress' ? Colors.white : Colors.white70))),
                                          const SizedBox(width: 8), // Spasi antar tombol kategori
                                          TextButton(onPressed: () {
                                            setState(() {
                                              _selectedCategoryFilter = 'Jenis';
                                            });
                                          }, child: Text('Jenis', style: TextStyle(color: _selectedCategoryFilter == 'Jenis' ? Colors.white : Colors.white70))),
                                          const SizedBox(width: 8), // Spasi antar tombol kategori
                                          TextButton(onPressed: () {
                                            setState(() {
                                              _selectedCategoryFilter = 'Harga';
                                            });
                                          }, child: Text('Harga', style: TextStyle(color: _selectedCategoryFilter == 'Harga' ? Colors.white : Colors.white70))),
                                          // Tambahkan lebih banyak kategori di sini jika diperlukan
                                          const SizedBox(width: 8),
                                          TextButton(onPressed: () {
                                            setState(() {
                                              _selectedCategoryFilter = 'Material';
                                            });
                                          }, child: Text('Material', style: TextStyle(color: _selectedCategoryFilter == 'Material' ? Colors.white : Colors.white70))),
                                          const SizedBox(width: 8),
                                          TextButton(onPressed: () {
                                            setState(() {
                                              _selectedCategoryFilter = 'Custom';
                                            });
                                          }, child: Text('Custom', style: TextStyle(color: _selectedCategoryFilter == 'Custom' ? Colors.white : Colors.white70))),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Tombol filter list (tetap di kanan)
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
                            ),

                            // 6. Product List (Scrollable)
                            // Menggunakan ConstrainedBox untuk membatasi tinggi ListView.builder
                            // agar SingleChildScrollView dapat bekerja dengan baik.
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height - // Tinggi total layar
                                            AppBar().preferredSize.height -      // Tinggi AppBar
                                            MediaQuery.of(context).padding.top - // Padding atas (notch, status bar)
                                            (20) - // Tambahan spasi awal
                                            (10.0 + 12.0*2 + 16.0*2) -           // Padding & content search bar
                                            100.0 -                              // Tinggi SizedBox di bawah search bar
                                            (8.0*2 + 20.0) -                     // Padding & content filter status (approx height)
                                            (8.0*2 + 20.0) -                     // Padding & content filter kategori (approx height)
                                            MediaQuery.of(context).viewInsets.bottom - // Mengurangi tinggi keyboard
                                            80, // Offset tambahan jika perlu, sesuaikan ini
                              ),
                              child: _filteredOrders.isEmpty
                                  ? Center(
                                      child: Text(
                                        _searchQuery.isNotEmpty
                                            ? 'Tidak ada pesanan cocok dengan pencarian Anda.'
                                            : 'Tidak ada pesanan aktif.',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      itemCount: _filteredOrders.length,
                                      itemBuilder: (context, index) {
                                        final order = _filteredOrders[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          color: Colors.white.withOpacity(0.9),
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
                    ),
        ],
      ),
    );
  }
}