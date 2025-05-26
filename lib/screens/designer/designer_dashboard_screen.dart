import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'designer_detail_screen.dart';

class DesignerDashboardScreen extends StatefulWidget {
  const DesignerDashboardScreen({super.key});

  @override
  State<DesignerDashboardScreen> createState() =>
      _DesignerDashboardScreenState();
}

class _DesignerDashboardScreenState extends State<DesignerDashboardScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  Object? _selectedStatusFilter;

  final List<OrderWorkflowStatus> waitingStatuses = [
    OrderWorkflowStatus.waiting_designer,
  ];

  final List<OrderWorkflowStatus> workingStatuses = [
    OrderWorkflowStatus.designing,
    // tambah status lain jika perlu (misal reviewing, dsb)
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userRole');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  List<Order> get _filteredOrders {
    List<Order> filtered =
        _orders
            .where(
              (order) =>
                  waitingStatuses.contains(order.workflowStatus) ||
                  workingStatuses.contains(order.workflowStatus),
            )
            .toList();

    if (_selectedStatusFilter == 'waiting') {
      filtered =
          filtered
              .where((order) => waitingStatuses.contains(order.workflowStatus))
              .toList();
    } else if (_selectedStatusFilter == 'working') {
      filtered =
          filtered
              .where((order) => workingStatuses.contains(order.workflowStatus))
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((order) {
            return order.customerName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();
    }
    return filtered;
  }

  Widget _buildStatusFilterButton(
    String label,
    String filterValue,
    Color color,
  ) {
    int count = 0;
    if (filterValue == 'waiting') {
      count =
          _orders
              .where((order) => waitingStatuses.contains(order.workflowStatus))
              .length;
    } else if (filterValue == 'working') {
      count =
          _orders
              .where((order) => workingStatuses.contains(order.workflowStatus))
              .length;
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
        title: const Text('Designer Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchOrders,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          _buildStatusFilterButton(
                            'Waiting',
                            'waiting',
                            Colors.orange,
                          ),
                          _buildStatusFilterButton(
                            'Working',
                            'working',
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        onChanged:
                            (value) => setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          labelText: 'Cari nama pelanggan',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          _filteredOrders.isEmpty
                              ? const Center(child: Text('Tidak ada pesanan.'))
                              : ListView.builder(
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _filteredOrders[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      leading:
                                          order.imagePaths != null &&
                                                  order
                                                      .imagePaths!
                                                      .isNotEmpty &&
                                                  order
                                                      .imagePaths!
                                                      .first
                                                      .isNotEmpty &&
                                                  File(
                                                    order.imagePaths!.first,
                                                  ).existsSync()
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                  File(order.imagePaths!.first),
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                              : const CircleAvatar(
                                                child: Icon(Icons.image),
                                              ),
                                      title: Text(order.customerName),
                                      subtitle: Text(
                                        'Status: ${order.workflowStatus.label}',
                                      ),
                                      onTap: () async {
                                        final result = await Navigator.of(
                                          context,
                                        ).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    DesignerDetailScreen(
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
    );
  }
}
