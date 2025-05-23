import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DesignerOrderDetailScreen extends StatelessWidget {
  final Order order;
  final VoidCallback onUpdate;

  const DesignerOrderDetailScreen({
    Key? key,
    required this.order,
    required this.onUpdate,
  }) : super(key: key);

  Future<void> _markAsDone(BuildContext context) async {
    final updatedOrder = order.copyWith(
      designStatus: DesignStatus.done,
      currentRole: 'cor', // Move to next role
    );
    final orderService = OrderService();
    try {
      await orderService.updateOrder(updatedOrder);
      onUpdate();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Design marked as done and submitted to COR.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update order: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final showDoneButton =
        order.currentRole == 'designer' &&
        order.designStatus == DesignStatus.designing;
    return Scaffold(
      appBar: AppBar(title: const Text('Order Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer: ${order.customerName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text('Status: ${order.designStatus?.name ?? "-"}'),
            Text('Current Role: ${order.currentRole ?? "-"}'),
            const SizedBox(height: 24),
            if (showDoneButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _markAsDone(context),
                  child: const Text('Done & Submit to COR'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
