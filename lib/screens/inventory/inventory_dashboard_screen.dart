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

  Widget _buildTabButton(String label, String value, Color color) {
    final bool selected = _selectedTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isLoading;
    final errorMessage = _errorMessage;
    final filteredOrders = _filteredOrders;
    final isInventoryTab = _selectedTab == 'data';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Inventory'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _buildTabButton('Waiting', 'waiting', Colors.orange),
                const SizedBox(width: 8),
                _buildTabButton('Working', 'working', Colors.green),
                const SizedBox(width: 8),
                _buildTabButton('Inventory', 'data', Colors.blue),
              ],
            ),
          ),
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
                        ? (_inventoryList.isEmpty
                            ? Center(child: Text('Tidak ada data inventory.'))
                            : RefreshIndicator(
                                onRefresh: _fetchInventoryList,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  itemCount: _inventoryList.length,
                                  itemBuilder: (context, index) {
                                    final item = _inventoryList[index];
                                    final mainImage = item.imagePaths.isNotEmpty ? item.imagePaths.first : null;
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
                                                  child: mainImage != null && mainImage.isNotEmpty
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
                                                        item.jewelryType,
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
                                                            item.goldType.isNotEmpty ? item.goldType : '-',
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
                                            Row(
                                              children: [
                                                const Icon(Icons.price_check, color: Color(0xFFBFA14A), size: 18),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Harga: \\${item.itemsPrice?.toStringAsFixed(0) ?? '-'}',
                                                  style: const TextStyle(fontSize: 13, color: Color(0xFF7C5E2C)),
                                                ),
                                                const SizedBox(width: 18),
                                                if (item.ringSize != null)
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.circle, color: Color(0xFFBFA14A), size: 18),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'Ring Size: \\${item.ringSize}',
                                                        style: const TextStyle(fontSize: 13, color: Color(0xFF7C5E2C)),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
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
                                                    // Navigasi ke detail inventory
                                                    final result = await Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) => InventoryDetailScreen(inventoryItem: item),
                                                      ),
                                                    );
                                                    if (result == true) _fetchInventoryList();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ))
                        : (filteredOrders.isEmpty
                            ? Center(
                                child: Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ada pesanan cocok dengan pencarian Anda.'
                                      : 'Tidak ada pesanan aktif.',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = filteredOrders[index];
                                  // Pilih gambar utama sesuai tab
                                  String? mainImage;
                                  if (_selectedTab == 'data') {
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
                                                child: mainImage != null && mainImage.isNotEmpty
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
                                              if (_selectedTab != 'data')
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
                                                  if (result == true) _fetchOrders();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                          ),
          ),
        ],
      ),
    );
  }
}