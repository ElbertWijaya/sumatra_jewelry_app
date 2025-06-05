import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DesignerTaskScreen extends StatefulWidget {
  final Order order;
  const DesignerTaskScreen({super.key, required this.order});

  @override
  State<DesignerTaskScreen> createState() => _DesignerTaskScreenState();
}

class _DesignerTaskScreenState extends State<DesignerTaskScreen> {
  late Order _order;
  bool _isProcessing = false;
  List<String> _designerChecklist = [];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _designerChecklist = List<String>.from(_order.designerWorkChecklist ?? []);
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        designerWorkChecklist: _designerChecklist,
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
      appBar: AppBar(title: const Text('Task Designer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CheckboxListTile(
            value: _designerChecklist.contains('Designing'),
            title: const Text('Designing'),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _designerChecklist.add('Designing');
                } else {
                  _designerChecklist.remove('Designing');
                }
              });
            },
          ),
          // Tambahkan checklist lain sesuai kebutuhan
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