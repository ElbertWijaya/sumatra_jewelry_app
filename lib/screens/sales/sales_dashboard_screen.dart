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
  bool _filterActive = false;

  final List<String> _categories = ['Progress', 'Jenis', 'Harga'];

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
      filtered =
          filtered
              .where((order) => order.status != OrderStatus.canceled)
              .toList();
    } else if (_selectedStatusFilter is OrderStatus) {
      filtered =
          filtered
              .where((order) => order.status == _selectedStatusFilter)
              .toList();
    } else if (_selectedStatusFilter == 'onProgress') {
      filtered =
          filtered
              .where(
                (order) =>
                    order.status != OrderStatus.pending &&
                    order.status != OrderStatus.completed &&
                    order.status != OrderStatus.canceled,
              )
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((order) {
            final query = _searchQuery.toLowerCase();
            return order.customerName.toLowerCase().contains(query) ||
                order.productName.toLowerCase().contains(query) ||
                order.status.toDisplayString().toLowerCase().contains(query);
          }).toList();
    }

    return filtered;
  }

  Widget _buildStatusFilterButton(
    String label,
    Object? filterValue,
    Color color,
  ) {
    int count;
    if (filterValue == null) {
      count =
          _orders.where((order) => order.status != OrderStatus.canceled).length;
    } else if (filterValue is OrderStatus) {
      count = _orders.where((order) => order.status == filterValue).length;
    } else if (filterValue == 'onProgress') {
      count =
          _orders
              .where(
                (order) =>
                    order.status != OrderStatus.pending &&
                    order.status != OrderStatus.completed &&
                    order.status != OrderStatus.canceled,
              )
              .length;
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
              color:
                  _selectedStatusFilter == filterValue
                      ? color.withOpacity(0.8)
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _selectedStatusFilter == filterValue ? color : Colors.grey,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        _selectedStatusFilter == filterValue
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color:
                        _selectedStatusFilter == filterValue
                            ? Colors.white
                            : color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color:
                          _selectedStatusFilter == filterValue
                              ? color
                              : Colors.white,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/toko_sumatra.jpg',
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : _errorMessage.isNotEmpty
              ? Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchOrders,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(
                        height:
                            AppBar().preferredSize.height +
                            MediaQuery.of(context).padding.top +
                            20,
                      ),
                      // 2. Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Search',
                            hintText: 'Cari nama pelanggan atau produk...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white70,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintStyle: const TextStyle(color: Colors.white54),
                            floatingLabelStyle: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 100.0),

                      // 4. Status Filter Tabs (Semua, Waiting, On Progress, Submitted)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusFilterButton(
                              'Semua',
                              null,
                              Colors.deepPurple,
                            ),
                            _buildStatusFilterButton(
                              'Waiting',
                              OrderStatus.pending,
                              Colors.orange,
                            ),
                            _buildStatusFilterButton(
                              'On Progress',
                              'onProgress',
                              Colors.blue,
                            ),
                            _buildStatusFilterButton(
                              'Submitted',
                              OrderStatus.completed,
                              Colors.green,
                            ),
                          ],
                        ),
                      ),

                      // 5. Categories Filter (Progress, Jenis, Harga) + Filter Icon
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            // Horizontally scrollable category filters
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      _categories.map((category) {
                                        final isSelected =
                                            _selectedCategoryFilter == category;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectedCategoryFilter =
                                                    category;
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              category,
                                              style: TextStyle(
                                                color:
                                                    isSelected
                                                        ? Colors.deepPurple
                                                        : Colors.white70,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                            // Filter icon in a square box, always on the right
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(left: 8.0),
                              decoration: BoxDecoration(
                                color:
                                    _filterActive
                                        ? Colors.deepPurple
                                        : Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.filter_list,
                                  color:
                                      _filterActive
                                          ? Colors.white
                                          : Colors.deepPurple,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _filterActive = !_filterActive;
                                    // TODO: Show filter modal/sheet if needed
                                  });
                                },
                                splashRadius: 22,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 6. Product List
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.of(context).size.height -
                              AppBar().preferredSize.height -
                              MediaQuery.of(context).padding.top -
                              (10.0 + 12.0 * 2 + 16.0 * 2) -
                              100.0 -
                              (8.0 * 2 + 20.0 + 16.0 * 2) -
                              (8.0 * 2 + 20.0 + 16.0 * 2) -
                              MediaQuery.of(context).viewInsets.bottom -
                              80,
                        ),
                        child:
                            _filteredOrders.isEmpty
                                ? Center(
                                  child: Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Tidak ada pesanan cocok dengan pencarian Anda.'
                                        : 'Tidak ada pesanan aktif.',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  itemCount: _filteredOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = _filteredOrders[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: Colors.white.withOpacity(0.9),
                                      child: ListTile(
                                        leading: const CircleAvatar(
                                          backgroundColor: Colors.blueGrey,
                                          child: Icon(
                                            Icons.image,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(
                                          order.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Produk: ${order.productName}',
                                            ),
                                            Text(
                                              'Status: ${order.status.toDisplayString()}',
                                              style: TextStyle(
                                                color:
                                                    order.status ==
                                                            OrderStatus.pending
                                                        ? Colors.orange
                                                        : order.status ==
                                                            OrderStatus
                                                                .completed
                                                        ? Colors.green
                                                        : order.status ==
                                                            OrderStatus.canceled
                                                        ? Colors.red
                                                        : Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey,
                                        ),
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      OrderDetailScreen(
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
