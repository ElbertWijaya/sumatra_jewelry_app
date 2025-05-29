import 'package:flutter/material.dart';
import '../../models/order.dart';

class SalesDetailScreen extends StatelessWidget {
  final Order order;
  const SalesDetailScreen({super.key, required this.order});

  Widget _buildChecklist(String title, List<String>? checklist) {
    if (checklist == null || checklist.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...checklist.map((item) => Row(
          children: [
            const Icon(Icons.check, color: Colors.green, size: 18),
            const SizedBox(width: 4),
            Text(item),
          ],
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Nama: ${order.customerName}'),
            Text('Kontak: ${order.customerContact}'),
            Text('Alamat: ${order.address}'),
            Text('Jenis: ${order.jewelryType}'),
            Text('Status: ${order.workflowStatus.label}'),
            const Divider(),
            _buildChecklist('Checklist Designer', order.designerWorkChecklist),
            _buildChecklist('Checklist Casting', order.castingWorkChecklist),
            _buildChecklist('Checklist Carving', order.carvingWorkChecklist),
            _buildChecklist('Checklist Diamond Setting', order.diamondSettingWorkChecklist),
            _buildChecklist('Checklist Finishing', order.finishingWorkChecklist),
            _buildChecklist('Checklist Inventory', order.inventoryWorkChecklist),
            // Tambahkan field lain sesuai kebutuhan
          ],
        ),
      ),
    );
  }
}