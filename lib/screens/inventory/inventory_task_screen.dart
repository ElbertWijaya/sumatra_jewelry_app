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
  List<String> _inventoryChecklist = [];
  bool _isProcessing = false;

  final List<String> _tasks = [
    'Cek stok',
    'Input data inventory',
    'Foto produk',
    'Verifikasi kualitas',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Checklist Worklist Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
        ..._tasks.map((task) => CheckboxListTile(
              value: _inventoryChecklist.contains(task),
              title: Text(task),
              onChanged: _isProcessing
                  ? null
                  : (val) {
                      setState(() {
                        if (val == true) {
                          if (!_inventoryChecklist.contains(task)) {
                            _inventoryChecklist.add(task);
                          }
                        } else {
                          _inventoryChecklist.remove(task);
                        }
                      });
                    },
            )),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _isProcessing ? null : _updateChecklist,
          child: _isProcessing
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Update Checklist'),
        ),
      ],
    );
  }
}