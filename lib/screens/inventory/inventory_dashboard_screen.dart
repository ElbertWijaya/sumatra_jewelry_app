import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/inventory.dart';
import '../../services/order_service.dart';
import '../../services/remote_inventory_service.dart';
import 'inventory_detail_screen.dart';

class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() => _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
  final OrderService _orderService = OrderService();
  final RemoteInventoryService _remoteInventoryService = RemoteInventoryService();
  List<Order> _orders = [];
  List<InventoryItem> _inventoryList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedTab = 'waiting'; // default tab inventory

  // Filter state
  List<String> selectedJewelryTypes = [];
  List<String> selectedGoldColors = [];
  List<String> selectedGoldTypes = [];
  List<String> selectedStoneTypes = [];
  double? priceMin;
  double? priceMax;
  String? ringSize;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchInventoryList();
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
        _errorMessage = 'Gagal memuat pesanan: ${e.toString().replaceAll('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchInventoryList() async {
    try {
      final data = await _remoteInventoryService.getInventoryList();
      setState(() {
        _inventoryList = data.map((e) => InventoryItem.fromMap(e)).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data inventory: \\${e.toString()}';
      });
    }
  }

  String orderFullText(Order order) {
    return [
      order.customerName,
      order.customerContact,
      order.address,
      order.jewelryType,
      order.stoneType,
      order.stoneSize,
      order.ringSize,
      order.readyDate?.toIso8601String() ?? '',
      order.pickupDate?.toIso8601String() ?? '',
      order.goldPricePerGram.toString(),
      order.finalPrice.toString(),
      order.notes,
      order.workflowStatus.label,
    ].join(' ').toLowerCase();
  }

  List<Order> get _filteredOrders {
    List<Order> filtered = _orders.where((order) =>
      order.workflowStatus != OrderWorkflowStatus.done &&
      order.workflowStatus != OrderWorkflowStatus.cancelled
    ).toList();

    // Tab logic khusus inventory
    if (_selectedTab == 'waiting') {
      filtered = filtered.where((order) =>
        order.workflowStatus == OrderWorkflowStatus.waitingInventory
      ).toList();
    } else if (_selectedTab == 'working') {
      filtered = filtered.where((order) =>
        order.workflowStatus == OrderWorkflowStatus.inventory
      ).toList();
    }

    // Filter kategori dari filter bar/sheet
    if (selectedJewelryTypes.isNotEmpty) {
      filtered = filtered.where((order) =>
        selectedJewelryTypes.any((t) => order.jewelryType.toLowerCase().contains(t.toLowerCase()))
      ).toList();
    }
    if (selectedGoldColors.isNotEmpty) {
      filtered = filtered.where((order) =>
        selectedGoldColors.any((gold) => orderFullText(order).contains(gold.toLowerCase()))
      ).toList();
    }
    if (selectedGoldTypes.isNotEmpty) {
      filtered = filtered.where((order) =>
        selectedGoldTypes.any((t) => orderFullText(order).contains(t.toLowerCase()))
      ).toList();
    }
    if (selectedStoneTypes.isNotEmpty) {
      filtered = filtered.where((order) =>
        selectedStoneTypes.any((stone) => order.stoneType.toLowerCase().contains(stone.toLowerCase()))
      ).toList();
    }
    if (priceMin != null) {
      filtered = filtered.where((order) => order.finalPrice >= priceMin!).toList();
    }
    if (priceMax != null) {
      filtered = filtered.where((order) => order.finalPrice <= priceMax!).toList();
    }
    if (ringSize != null && ringSize!.isNotEmpty) {
      filtered = filtered.where((order) => order.ringSize.toLowerCase().contains(ringSize!.toLowerCase())).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) =>
        orderFullText(order).contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  // Tambahkan fungsi untuk filter inventory
  List<InventoryItem> get _filteredInventory {
    List<InventoryItem> filtered = List.from(_inventoryList);
    if (selectedJewelryTypes.isNotEmpty) {
      filtered = filtered.where((item) =>
        selectedJewelryTypes.any((t) => item.jewelryType.toLowerCase().contains(t.toLowerCase()))
      ).toList();
    }
    if (selectedGoldColors.isNotEmpty) {
      filtered = filtered.where((item) =>
        selectedGoldColors.any((gold) => item.goldColor.toLowerCase().contains(gold.toLowerCase()))
      ).toList();
    }
    if (selectedGoldTypes.isNotEmpty) {
      filtered = filtered.where((item) =>
        selectedGoldTypes.any((t) => item.goldType.toLowerCase().contains(t.toLowerCase()))
      ).toList();
    }
    if (priceMin != null) {
      filtered = filtered.where((item) => (item.itemsPrice ?? 0) >= priceMin!).toList();
    }
    if (priceMax != null) {
      filtered = filtered.where((item) => (item.itemsPrice ?? 0) <= priceMax!).toList();
    }
    if (ringSize != null && ringSize!.isNotEmpty) {
      filtered = filtered.where((item) => (item.ringSize ?? '').toLowerCase().contains(ringSize!.toLowerCase())).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) =>
        [item.id, item.jewelryType, item.goldType, item.goldColor, item.ringSize, item.itemsPrice?.toString() ?? '', item.createdAt ?? '']
          .join(' ').toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return filtered;
  }

  Widget _buildTabButton(String label, String value, Color color, int count) {
    final bool selected = _selectedTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.8) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : Colors.grey,
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
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? color : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteInventory(int inventoryId) async {
    try {
      final response = await RemoteInventoryService().deleteInventory(inventoryId);
      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data inventory berhasil dihapus')),
        );
        await _fetchInventoryList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus data inventory')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \\${e.toString()}')),
      );
    }
  }

  // Tambahkan fungsi format rupiah
  String _formatRupiah(num? value) {
    if (value == null) return '-';
    final str = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    final formatted = buffer.toString().split('').reversed.join();
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isLoading;
    final errorMessage = _errorMessage;
    final filteredOrders = _filteredOrders;
    final filteredInventory = _filteredInventory;
    final isInventoryTab = _selectedTab == 'data';
    final allFilters = [
      ...selectedJewelryTypes,
      ...selectedGoldColors,
      ...selectedGoldTypes,
      ...selectedStoneTypes,
      if (ringSize != null && ringSize!.isNotEmpty) 'Ring Size: $ringSize',
    ];
    final selectedFilters = allFilters.where((e) => e.isNotEmpty).toList();
    final filterBarList = [
      ...selectedFilters,
      ...['Ring', 'Bangle', 'Earrings', 'Necklace', 'Bracelet', 'Pendant', 'Men Ring', 'Women Ring', 'White Gold', 'Rose Gold', 'Yellow Gold', '24K', '22K', '19K', '18K', '14K', '10K', '9K']
        .where((f) => !selectedFilters.contains(f)),
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Dashboard Inventory'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () async { await _fetchOrders(); await _fetchInventoryList(); }),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/toko_sumatra.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() { _searchQuery = value; });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Cari nama, jenis, emas, harga, dsb...',
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: const TextStyle(color: Colors.white54),
                      floatingLabelStyle: const TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 70.0),
                // Filter bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: filterBarList.map((cat) {
                              final isSelected = selectedFilters.contains(cat);
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                                  selected: isSelected,
                                  backgroundColor: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                                  selectedColor: const Color(0xFFD4AF37),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (isSelected) {
                                        selectedJewelryTypes.remove(cat);
                                        selectedGoldColors.remove(cat);
                                        selectedGoldTypes.remove(cat);
                                        selectedStoneTypes.remove(cat);
                                      } else {
                                        if (['Ring', 'Bangle', 'Earrings', 'Necklace', 'Bracelet', 'Pendant', 'Men Ring', 'Women Ring'].contains(cat)) selectedJewelryTypes.add(cat);
                                        if (['White Gold', 'Rose Gold', 'Yellow Gold'].contains(cat)) selectedGoldColors.add(cat);
                                        if (['24K', '22K', '19K', '18K', '14K', '10K', '9K'].contains(cat)) selectedGoldTypes.add(cat);
                                      }
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                        onPressed: () {
                          // TODO: Implement filter sheet/modal jika ingin seperti dashboard lain
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildTabButton('Waiting', 'waiting', Colors.orange, _orders.where((o) => o.workflowStatus == OrderWorkflowStatus.waitingInventory).length),
                      const SizedBox(width: 8),
                      _buildTabButton('Working', 'working', Colors.green, _orders.where((o) => o.workflowStatus == OrderWorkflowStatus.inventory).length),
                      const SizedBox(width: 8),
                      _buildTabButton('Inventory', 'data', Colors.blue, _inventoryList.length),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                // Expanded: List data
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage.isNotEmpty
                          ? Center(
                              child: Text(
                                errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : isInventoryTab
                              ? _buildInventoryList()
                              : _buildOrderList(filteredOrders, _searchQuery, _selectedTab, _fetchOrders),
                ),
              ], // end children Column
            ), // end Column
          ), // end SafeArea
        ], // end children Stack
      ), // end Stack
    ); // end Scaffold
  } // end build

  Widget _buildInventoryList() {
    if (_filteredInventory.isEmpty) {
      return const Center(
        child: Text('Tidak ada data inventory.', style: TextStyle(color: Colors.white70)),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchInventoryList,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _filteredInventory.length,
        itemBuilder: (context, index) {
          final item = _filteredInventory[index];
          final mainImage = item.imagePaths.isNotEmpty ? item.imagePaths.first : null;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => InventoryDetailScreen(inventoryItem: item),
                ),
              );
              if (result == true) await _fetchInventoryList();
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: mainImage != null && mainImage.isNotEmpty
                              ? Image.network(
                                  mainImage,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.brown[100],
                                    child: const Icon(Icons.image, size: 36, color: Colors.brown),
                                  ),
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.brown[100],
                                  child: const Icon(Icons.image, size: 36, color: Colors.brown),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text('ID: ${item.id}', style: const TextStyle(fontSize: 13, color: Colors.grey), overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.jewelryType,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF7C5E2C)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatRupiah(item.itemsPrice),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD4AF37)),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.color_lens, color: Color(0xFFD4AF37), size: 16),
                                  const SizedBox(width: 2),
                                  Flexible(child: Text(item.goldColor, style: const TextStyle(fontSize: 13, color: Color(0xFF7C5E2C)), overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.grade, color: Color(0xFFD4AF37), size: 16),
                                  const SizedBox(width: 2),
                                  Flexible(child: Text(item.goldType, style: const TextStyle(fontSize: 13, color: Color(0xFF7C5E2C)), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.grey, size: 13),
                                  const SizedBox(width: 2),
                                  Flexible(child: Text('Input: ${item.createdAt ?? '-'}', style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.update, color: Colors.grey, size: 13),
                                  const SizedBox(width: 2),
                                  Flexible(child: Text('Upd: ${item.updatedAt ?? '-'}', style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Tombol edit & hapus di pojok kanan atas
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                            tooltip: 'Edit',
                            onPressed: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => InventoryDetailScreen(inventoryItem: item, isEdit: true),
                                ),
                              );
                              if (result == true) _fetchInventoryList();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            tooltip: 'Hapus',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi Hapus'),
                                  content: Text('Yakin ingin menghapus data inventory dengan ID ${item.id}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                if (item.inventoryId != null) {
                                  await _deleteInventory(item.inventoryId!);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('ID inventory tidak ditemukan!')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
          },
        ),
      );
    }
  }

  Widget _buildOrderList(List orders, String searchQuery, String selectedTab, Future<void> Function()? onRefreshOrders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isNotEmpty
              ? 'Tidak ada pesanan cocok dengan pencarian Anda.'
              : 'Tidak ada pesanan aktif.',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        String? mainImage;
        if (selectedTab == 'data') {
          mainImage = (order.inventoryImagePaths != null && order.inventoryImagePaths!.isNotEmpty)
              ? order.inventoryImagePaths!.first
              : null;
        } else {
          mainImage = order.imagePaths.isNotEmpty ? order.imagePaths.first : null;
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: const Color(0xFFFDF6E3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (mainImage != null && mainImage.isNotEmpty)
                          ? Image.network(
                              mainImage,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 90,
                                height: 90,
                                color: Colors.brown[100],
                                child: const Icon(Icons.image, size: 40, color: Colors.brown),
                              ),
                            )
                          : Container(
                              width: 90,
                              height: 90,
                              color: Colors.brown[100],
                              child: const Icon(Icons.image, size: 40, color: Colors.brown),
                            ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF7C5E2C),
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.category, color: Color(0xFFD4AF37), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                order.jewelryType.isNotEmpty == true ? order.jewelryType : "-",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF7C5E2C),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Row kedua: info tanggal, status, tombol
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFFBFA14A), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Order: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF7C5E2C)),
                    ),
                    const SizedBox(width: 18),
                    if (order.pickupDate != null)
                      Row(
                        children: [
                          const Icon(Icons.assignment_turned_in, color: Color(0xFFBFA14A), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Ambil: ${order.pickupDate!.day}/${order.pickupDate!.month}/${order.pickupDate!.year}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF7C5E2C)),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (selectedTab != 'data')
                      Chip(
                        label: Text(
                          order.workflowStatus.label,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFFD4AF37),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text('Detail', style: TextStyle(fontSize: 13)),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => InventoryDetailScreen(order: order),
                          ),
                        );
                        if (result == true && onRefreshOrders != null) await onRefreshOrders();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
