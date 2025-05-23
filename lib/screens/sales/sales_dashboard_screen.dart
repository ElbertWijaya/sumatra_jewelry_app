import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'sales_detail_screen.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({Key? key}) : super(key: key);

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

  // Daftar status waiting (pending & waiting_sales_completion)
  final List<OrderWorkflowStatus> waitingStatuses = [
    OrderWorkflowStatus.pending,
    OrderWorkflowStatus.waiting_sales_completion,
  ];

  // Hanya status aktif yang boleh tampil
  final List<OrderWorkflowStatus> activeStatuses = [
    OrderWorkflowStatus.pending,
    OrderWorkflowStatus.waiting_sales_completion,
    // Tambahkan status aktif lain jika ada!
  ];

  // Daftar kategori (tidak diubah, hanya contoh default)
  final List<String> categories = [
    'Progress',
    'Jenis',
    'Harga',
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

  /// Menggabungkan seluruh info pesanan (yang tampil di halaman detail) jadi satu string untuk pencarian kategori
  String orderFullText(Order order) {
    // Tambahkan field lain sesuai yang ditampilkan di halaman detail
    return [
    order.customerName,
    order.customerContact,
    order.address,
    order.jewelryType,
    order.stoneType ?? '',
    order.stoneSize ?? '',
    order.ringSize ?? '',
    order.readyDate?.toIso8601String() ?? '',
    order.pickupDate?.toIso8601String() ?? '',
    order.goldPricePerGram?.toString() ?? '',
    order.finalPrice?.toString() ?? '',
    order.notes ?? '',
    order.workflowStatus.label,
    order.assignedDesigner ?? '',
    order.assignedCaster ?? '',
    order.assignedCarver ?? '',
    order.assignedDiamondSetter ?? '',
    order.assignedFinisher ?? '',
    order.assignedInventory ?? '',
      // dst (field lain bisa ditambah di sini)
    ].join(' ').toLowerCase();
  }

  List<Order> get _filteredOrders {
    // Pesanan selesai/dibatalkan otomatis tidak tampil
    List<Order> filtered = _orders.where((order) => activeStatuses.contains(order.workflowStatus)).toList();

    // Filter kategori (jika ada dipilih & bukan Progress/Jenis/Harga)
    if (_selectedCategoryFilter != null &&
        _selectedCategoryFilter!.isNotEmpty &&
        !_isDefaultCategory(_selectedCategoryFilter!)) {
      filtered = filtered.where((order) {
        return orderFullText(order).contains(_selectedCategoryFilter!.toLowerCase());
      }).toList();
    }

    if (_selectedStatusFilter == null) {
      // Tampilkan semua status aktif saja
    } else if (_selectedStatusFilter == 'waiting') {
      filtered = filtered
          .where((order) => waitingStatuses.contains(order.workflowStatus))
          .toList();
    } else if (_selectedStatusFilter is OrderWorkflowStatus) {
      filtered = filtered
          .where((order) => order.workflowStatus == _selectedStatusFilter)
          .toList();
    } else if (_selectedStatusFilter == 'onProgress') {
      // Filter onProgress: status aktif tapi bukan waiting
      filtered = filtered
          .where(
            (order) =>
                !waitingStatuses.contains(order.workflowStatus),
          )
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return orderFullText(order).contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  bool _isDefaultCategory(String? value) {
    // Kategori default (Progress/Jenis/Harga) hanya untuk tampilan visual, tidak untuk filter keyword
    return value == 'Progress' || value == 'Jenis' || value == 'Harga';
  }

  Widget _buildStatusFilterButton(
    String label,
    Object? filterValue,
    Color color,
  ) {
    int count;
    if (filterValue == null) {
      count = _orders.where((order) => activeStatuses.contains(order.workflowStatus)).length;
    } else if (filterValue == 'waiting') {
      count = _orders.where((order) => waitingStatuses.contains(order.workflowStatus)).length;
    } else if (filterValue is OrderWorkflowStatus) {
      count = _orders.where((order) => order.workflowStatus == filterValue).length;
    } else if (filterValue == 'onProgress') {
      // On progress = aktif tapi bukan waiting
      count = _orders
          .where((order) =>
              activeStatuses.contains(order.workflowStatus) &&
              !waitingStatuses.contains(order.workflowStatus))
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

  // Call this when an order is completed/cancelled to prepare for archiving
  Future<void> handleOrderCompletionOrCancellation(Order order) async {
    // TODO: Implement archiving logic here (copy order to archive database/table)
    // Example:
    // await ArchiveService().archiveOrder(order);
    // await OrderService().deleteOrder(order.id);
    // Setelah itu, refresh list
    await _fetchOrders();
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
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/sales/create').then((value) {
            if (value == true) _fetchOrders();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pesanan'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background
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
                            // Search bar
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
                                  hintText:
                                      'Cari nama pelanggan atau jenis perhiasan...',
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
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  hintStyle:
                                      const TextStyle(color: Colors.white54),
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 100.0),
                            // Status Filter Tabs
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
                                    'waiting',
                                    Colors.orange,
                                  ),
                                  _buildStatusFilterButton(
                                    'On Progress',
                                    'onProgress',
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                            // Category Filter: scroll horizontal, icon filter kanan
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  // Scrollable category
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(
                                            categories.length, (index) {
                                          final cat = categories[index];
                                          final isSelected = _selectedCategoryFilter == cat;
                                          return Padding(
                                            padding: EdgeInsets.only(right: 4.0),
                                            child: ChoiceChip(
                                              label: Text(cat),
                                              selected: isSelected,
                                              onSelected: (_) {
                                                setState(() {
                                                  _selectedCategoryFilter =
                                                      isSelected ? null : cat;
                                                });
                                              },
                                              selectedColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              labelStyle: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white70,
                                              ),
                                              backgroundColor: Colors.white.withOpacity(0.15),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                  // Icon filter selalu di kanan
                                  IconButton(
                                    icon: const Icon(
                                      Icons.filter_list,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Filter lebih lanjut akan ditambahkan!',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
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
                              child: _filteredOrders.isEmpty
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

                                        // Tampilkan gambar jika ada, jika tidak tampilkan icon default
                                        Widget leadingWidget;
                                        if (order.imagePaths != null &&
                                            order.imagePaths!.isNotEmpty &&
                                            order.imagePaths!.first.isNotEmpty &&
                                            File(
                                              order.imagePaths!.first,
                                            ).existsSync()) {
                                          leadingWidget = ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.file(
                                              File(order.imagePaths!.first),
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) =>
                                                      const Icon(
                                                        Icons.image_not_supported,
                                                        size: 32,
                                                        color: Colors.grey,
                                                      ),
                                            ),
                                          );
                                        } else {
                                          leadingWidget = const CircleAvatar(
                                            backgroundColor: Colors.blueGrey,
                                            radius: 40,
                                            child: Icon(
                                              Icons.image,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          );
                                        }

                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          color:
                                              Colors.white.withOpacity(0.9),
                                          child: ListTile(
                                            leading: leadingWidget,
                                            minLeadingWidth: 90,
                                            contentPadding:
                                                const EdgeInsets.all(8),
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
                                                Text('Jenis: ${order.jewelryType}'),
                                                Text(
                                                  'Status: ${order.workflowStatus.label}',
                                                  style: TextStyle(
                                                    color: order.workflowStatus ==
                                                            OrderWorkflowStatus
                                                                .pending
                                                        ? Colors.orange
                                                        : order.workflowStatus ==
                                                                OrderWorkflowStatus
                                                                    .done
                                                            ? Colors.green
                                                            : order.workflowStatus ==
                                                                    OrderWorkflowStatus
                                                                        .cancelled
                                                                ? Colors.red
                                                                : order.workflowStatus ==
                                                                        OrderWorkflowStatus
                                                                            .waiting_sales_completion
                                                                    ? Colors.orange
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
                                              // Navigasi ke halaman detail & edit
                                              final result =
                                                  await Navigator.of(
                                                context,
                                              ).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          SalesDetailScreen(
                                                            order: order,
                                                          ),
                                                ),
                                              );
                                              if (result == true) _fetchOrders();
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