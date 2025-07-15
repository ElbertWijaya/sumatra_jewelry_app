import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class FinisherTaskScreen extends StatefulWidget {
  final Order order;
  const FinisherTaskScreen({super.key, required this.order});

  @override
  State<FinisherTaskScreen> createState() => _FinisherTaskScreenState();
}

class _FinisherTaskScreenState extends State<FinisherTaskScreen> {
  late Order _order;
  bool _isProcessing = false;
  List<String> _finisherChecklist = [];

  final List<String> _finisherTasks = ['Finishing', 'Kasih ke Admin'];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _finisherChecklist = List<String>.from(_order.finishingWorkChecklist ?? []);
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        finishingWorkChecklist: _finisherChecklist,
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
      appBar: AppBar(title: const Text('Task Finisher')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._finisherTasks.map(
            (task) => CheckboxListTile(
              value: _finisherChecklist.contains(task),
              title: Text(task),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _finisherChecklist.add(task);
                  } else {
                    _finisherChecklist.remove(task);
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
