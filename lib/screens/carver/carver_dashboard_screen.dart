import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class CarverDashboardScreen extends StatefulWidget {
  const CarverDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CarverDashboardScreen> createState() => _CarverDashboardScreenState();
}

class _CarverDashboardScreenState extends State<CarverDashboardScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  List<Order> _orders = [];

  int _pending = 0;
  int _processing = 0;
  int _delivered = 0;
  int _cancelled = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.getOrders();
      // Only show orders for carver, or remove this filter to see all
      final filteredOrders =
          orders.where((order) => order.currentRole == 'carver').toList();

      int pending = 0, processing = 0, delivered = 0, cancelled = 0;
      for (final order in filteredOrders) {
        switch (order.status) {
          case OrderStatus.pending:
            pending++;
            break;
          case OrderStatus.processing:
            processing++;
            break;
          case OrderStatus.delivered:
            delivered++;
            break;
          case OrderStatus.cancelled:
            cancelled++;
            break;
          default:
            break;
        }
      }
      setState(() {
        _orders = filteredOrders;
        _pending = pending;
        _processing = processing;
        _delivered = delivered;
        _cancelled = cancelled;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dashboard data: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          count.toString(),
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: color),
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    final recentOrders = List<Order>.from(_orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final displayedOrders = recentOrders.take(5).toList();
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Recent Orders',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          if (displayedOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No recent orders.'),
            )
          else
            ...displayedOrders.map(
              (order) => ListTile(
                title: Text(order.customerName),
                subtitle: Text('${order.status.label} • ${order.createdAt}'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carver Dashboard')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchDashboardData,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                            icon: Icons.hourglass_empty,
                            label: 'Pending',
                            count: _pending,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusCard(
                            icon: Icons.sync,
                            label: 'Processing',
                            count: _processing,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                            icon: Icons.check_circle,
                            label: 'Delivered',
                            count: _delivered,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusCard(
                            icon: Icons.cancel,
                            label: 'Cancelled',
                            count: _cancelled,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    _buildRecentOrders(),
                  ],
                ),
              ),
    );
  }
}
