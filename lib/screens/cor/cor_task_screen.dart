import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class CasterTaskScreen extends StatefulWidget {
  final Order order;
  const CasterTaskScreen({super.key, required this.order});

  @override
  State<CasterTaskScreen> createState() => _CasterTaskScreenState();
}

class _CasterTaskScreenState extends State<CasterTaskScreen> {
  late Order _order;
  bool _isProcessing = false;
  List<String> _casterChecklist = [];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _casterChecklist = List<String>.from(_order.castingWorkChecklist ?? []);
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        castingWorkChecklist: _casterChecklist,
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
      appBar: AppBar(title: const Text('Task Caster')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CheckboxListTile(
            value: _casterChecklist.contains('Casting'),
            title: const Text('Casting'),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _casterChecklist.add('Casting');
                } else {
                  _casterChecklist.remove('Casting');
                }
              });
            },
          ),
          CheckboxListTile(
            value: _casterChecklist.contains('Pengecoran'),
            title: const Text('Pengecoran'),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _casterChecklist.add('Pengecoran');
                } else {
                  _casterChecklist.remove('Pengecoran');
                }
              });
            },
          ),
          CheckboxListTile(
            value: _casterChecklist.contains('Pengecekan Cor'),
            title: const Text('Pengecekan Cor'),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _casterChecklist.add('Pengecekan Cor');
                } else {
                  _casterChecklist.remove('Pengecekan Cor');
                }
              });
            },
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