import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'designer_order_detail_screen.dart';

class DesignerDashboardScreen extends StatefulWidget {
  const DesignerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DesignerDashboardScreen> createState() =>
      _DesignerDashboardScreenState();
}

class _DesignerDashboardScreenState extends State<DesignerDashboardScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.getOrders();
      setState(() {
        _orders = orders.where((o) => o.currentRole == 'designer').toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _startDesign(Order order) async {
    final updatedOrder = order.copyWith(designStatus: DesignStatus.designing);
    setState(() => _isLoading = true);
    try {
      await _orderService.updateOrder(updatedOrder);
      _fetchOrders();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start design: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final waitingOrders =
        _orders.where((o) => o.designStatus == DesignStatus.waiting).toList();
    final designingOrders =
        _orders.where((o) => o.designStatus == DesignStatus.designing).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Designer Dashboard')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchOrders,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Waiting for Design',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...waitingOrders.isEmpty
                        ? [const Text('No orders waiting for design.')]
                        : waitingOrders.map(
                          (order) => ListTile(
                            title: Text(order.customerName),
                            subtitle: Text(
                              'Submitted by Sales • ${order.createdAt}',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _startDesign(order),
                              child: const Text('Start Design'),
                            ),
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => DesignerOrderDetailScreen(
                                          order: order,
                                          onUpdate: _fetchOrders,
                                        ),
                                  ),
                                ),
                          ),
                        ),
                    const SizedBox(height: 24),
                    const Text(
                      'Designing',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...designingOrders.isEmpty
                        ? [const Text('No orders in design.')]
                        : designingOrders.map(
                          (order) => ListTile(
                            title: Text(order.customerName),
                            subtitle: Text('Designing • ${order.createdAt}'),
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => DesignerOrderDetailScreen(
                                          order: order,
                                          onUpdate: _fetchOrders,
                                        ),
                                  ),
                                ),
                          ),
                        ),
                  ],
                ),
              ),
    );
  }
}
