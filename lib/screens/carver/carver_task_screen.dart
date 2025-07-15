import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class CarverTaskScreen extends StatefulWidget {
  final Order order;
  const CarverTaskScreen({super.key, required this.order});

  @override
  State<CarverTaskScreen> createState() => _CarverTaskScreenState();
}

class _CarverTaskScreenState extends State<CarverTaskScreen> {
  late Order _order;
  bool _isProcessing = false;
  List<String> _carverChecklist = [];

  final List<String> _carverTasks = [
    'Bom',
    'Polish',
    'Pengecekan',
    'Kasih ke Admin',
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _carverChecklist = List<String>.from(_order.carvingWorkChecklist ?? []);
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        carvingWorkChecklist: _carverChecklist,
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
      appBar: AppBar(title: const Text('Task Carver')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._carverTasks.map(
            (task) => CheckboxListTile(
              value: _carverChecklist.contains(task),
              title: Text(task),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _carverChecklist.add(task);
                  } else {
                    _carverChecklist.remove(task);
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _updateChecklist,
            child:
                _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('Update Checklist'),
          ),
        ],
      ),
    );
  }
}
