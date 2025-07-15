import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DiamondSetterTaskScreen extends StatefulWidget {
  final Order order;
  const DiamondSetterTaskScreen({super.key, required this.order});

  @override
  State<DiamondSetterTaskScreen> createState() =>
      _DiamondSetterTaskScreenState();
}

class _DiamondSetterTaskScreenState extends State<DiamondSetterTaskScreen> {
  late Order _order;
  bool _isProcessing = false;
  List<String> _diamondSetterChecklist = [];

  final List<String> _diamondSetterTasks = [
    'Milih Berlian',
    'Pasang Berlian',
    'Kasih ke Admin',
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _diamondSetterChecklist = List<String>.from(
      _order.diamondSettingWorkChecklist ?? [],
    );
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        diamondSettingWorkChecklist: _diamondSetterChecklist,
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
      appBar: AppBar(title: const Text('Task Diamond Setter')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._diamondSetterTasks.map(
            (task) => CheckboxListTile(
              value: _diamondSetterChecklist.contains(task),
              title: Text(task),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _diamondSetterChecklist.add(task);
                  } else {
                    _diamondSetterChecklist.remove(task);
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
