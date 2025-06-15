import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class InventoryTaskScreen extends StatefulWidget {
  final Order order;
  const InventoryTaskScreen({super.key, required this.order});

  @override
  State<InventoryTaskScreen> createState() => _InventoryTaskScreenState();
}

class _InventoryTaskScreenState extends State<InventoryTaskScreen> {
  late Order _order;
  bool _isProcessing = false;
  List<String> _inventoryChecklist = [];

  final List<String> _inventoryTasks = [
    'Cek Barang Masuk',
    'Cek Kelengkapan',
    'Input Stok',
    'Cek Kualitas',
    'Serahkan ke Finishing',
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _inventoryChecklist = List<String>.from(_order.inventoryWorkChecklist ?? []);
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        inventoryWorkChecklist: _inventoryChecklist,
      );
      await OrderService().updateOrder(updatedOrder);
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist berhasil diupdate')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Inventory')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._inventoryTasks.map(
            (task) => CheckboxListTile(
              value: _inventoryChecklist.contains(task),
              title: Text(task),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _inventoryChecklist.add(task);
                  } else {
                    _inventoryChecklist.remove(task);
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _updateChecklist,
            child: _isProcessing
                ? const CircularProgressIndicator()
                : const Text('Update Checklist'),
          ),
        ],
      ),
    );
  }
}