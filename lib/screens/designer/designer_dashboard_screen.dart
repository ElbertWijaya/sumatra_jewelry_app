import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'designer_detail_screen.dart';

class DesignerDashboardScreen extends StatefulWidget {
  const DesignerDashboardScreen({Key? key}) : super(key: key);

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
    if (_selectedStatusFilter is OrderWorkflowStatus) {
      filtered =
          filtered
              .where((order) => order.workflowStatus == _selectedStatusFilter)
              .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((order) {
            final query = _searchQuery.toLowerCase();
            return order.customerName.toLowerCase().contains(query) ||
                order.jewelryType.toLowerCase().contains(query) ||
                order.workflowStatus.label.toLowerCase().contains(query);
          }).toList();
    }
    return filtered;
  }

  Widget _buildStatusFilterButton(
    String label,
    OrderWorkflowStatus? filterValue,
    Color color,
  ) {
    int count =
        filterValue == null
            ? _orders.length
            : _orders
                .where((order) => order.workflowStatus == filterValue)
                .length;
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusFilterButton(
                              'Waiting',
                              OrderWorkflowStatus.pending,
                              Colors.orange,
                            ),
                            _buildStatusFilterButton(
                              'On Progress',
                              OrderWorkflowStatus.designing,
                              Colors.blue,
                            ),
                            _buildStatusFilterButton(
                              'Selesai',
                              OrderWorkflowStatus.done,
                              Colors.green,
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
                        child:
                            _filteredOrders.isEmpty
                                ? Center(
                                  child: Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Tidak ada pesanan cocok dengan pencarian Anda.'
                                        : 'Tidak ada pesanan.',
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

                                    Widget leadingWidget;
                                    if (order.imagePaths != null &&
                                        order.imagePaths!.isNotEmpty &&
                                        order.imagePaths!.first.isNotEmpty &&
                                        File(
                                          order.imagePaths!.first,
                                        ).existsSync()) {
                                      leadingWidget = ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: Colors.white.withOpacity(0.9),
                                      child: ListTile(
                                        leading: leadingWidget,
                                        minLeadingWidth: 90,
                                        contentPadding: const EdgeInsets.all(8),
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
                                                color:
                                                    order.workflowStatus ==
                                                            OrderWorkflowStatus
                                                                .pending
                                                        ? Colors.orange
                                                        : order.workflowStatus ==
                                                            OrderWorkflowStatus
                                                                .done
                                                        ? Colors.green
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
              ),
        ],
      ),
    );
  }
}
