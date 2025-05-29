import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order.dart';

class TestDashboard extends StatefulWidget {
  const TestDashboard({super.key});

  @override
  State<TestDashboard> createState() => _TestDashboardState();
}

class _TestDashboardState extends State<TestDashboard> {
  final OrderService _orderService = OrderService();
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Dashboard')),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('Tidak ada pesanan.'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final imageUrl = order.imagePaths.isNotEmpty ? order.imagePaths[0] : null;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.image),
                        )
                      : const Icon(Icons.image),
                  title: Text(order.customerName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text ('Nama Customer: ${order.customerName}'),
                      Text('Jenis: ${order.jewelryType}'),
                      Text('Tgl Pesan: ${order.createdAt.toString().split(' ').first}'),
                      Text('Tgl Siap: ${order.readyDate != null ? "${order.readyDate!.day}/${order.readyDate!.month}/${order.readyDate!.year}" : "-"}'),
                      Text('Status: ${order.workflowStatus.label}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}