import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'cor_detail_screen.dart';

class CorDashboardScreen extends StatefulWidget {
  const CorDashboardScreen({super.key});

  @override
  State<CorDashboardScreen> createState() => _CorDashboardScreenState();
}

class _CorDashboardScreenState extends State<CorDashboardScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedTab = 'waiting';

  // Status list untuk tab
  final List<OrderWorkflowStatus> waitingStatuses = [
    OrderWorkflowStatus.waitingCasting,
  ];
  final List<OrderWorkflowStatus> workingStatuses = [
    OrderWorkflowStatus.casting,
  ];
  final List<OrderWorkflowStatus> onProgressStatuses = [
    OrderWorkflowStatus.waitingCarving,
    OrderWorkflowStatus.carving,
    OrderWorkflowStatus.waitingDiamondSetting,
    OrderWorkflowStatus.stoneSetting,
    OrderWorkflowStatus.waitingFinishing,
    OrderWorkflowStatus.finishing,
    OrderWorkflowStatus.waitingInventory,
    OrderWorkflowStatus.inventory,
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
        _errorMessage = 'Gagal memuat pesanan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Order> get _filteredOrders {
    List<Order> filtered = _orders;
    if (_selectedTab == 'waiting') {
      filtered = filtered.where((order) => waitingStatuses.contains(order.workflowStatus)).toList();
    } else if (_selectedTab == 'working') {
      filtered = filtered.where((order) => workingStatuses.contains(order.workflowStatus)).toList();
    } else if (_selectedTab == 'onprogress') {
      filtered = filtered.where((order) => onProgressStatuses.contains(order.workflowStatus)).toList();
    }
    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) =>
        (order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        (order.jewelryType.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    return filtered;
  }

  Widget _buildTabButton(String label, String value, Color color) {
    final selected = _selectedTab == value;
    int count = 0;
    if (value == 'waiting') {
      count = _orders.where((order) => waitingStatuses.contains(order.workflowStatus)).length;
    } else if (value == 'working') {
      count = _orders.where((order) => workingStatuses.contains(order.workflowStatus)).length;
    } else if (value == 'onprogress') {
      count = _orders.where((order) => onProgressStatuses.contains(order.workflowStatus)).length;
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
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
      ),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cor Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
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
                hintText: 'Cari nama pelanggan atau jenis perhiasan...',
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
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton('Waiting', 'waiting', Colors.orange),
                _buildTabButton('Working', 'working', Colors.blue),
                _buildTabButton('On Progress', 'onprogress', Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchOrders,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        )
                      : _filteredOrders.isEmpty
                          ? Center(
                              child: Text(
                                _searchQuery.isNotEmpty
                                    ? 'Tidak ada pesanan cocok dengan pencarian Anda.'
                                    : 'Tidak ada pesanan aktif.',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];
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
                                          children: [
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
                                                await Navigator.of(context).push(
                                                  MaterialPageRoute(builder: (_) => CorDetailScreen(orderId: order.id)),
                                                );
                                                // Setelah kembali dari detail, bisa juga refresh list dashboard jika perlu
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        // Info pesanan lain bisa ditambahkan di sini
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}