import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DesignerTaskScreen extends StatefulWidget {
  final Order order;
  final Function(List<String> checklist) onSubmit;

  const DesignerTaskScreen({
    super.key,
    required this.order,
    required this.onSubmit,
  });

  @override
  State<DesignerTaskScreen> createState() => _DesignerTaskScreenState();
}

class _DesignerTaskScreenState extends State<DesignerTaskScreen> {
  final List<String> _tasks = ['Designing', '3D Printing', 'Pengecekan'];
  late List<String> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List<String>.from(widget.order.designerWorkChecklist ?? []);
  }

  bool get _allChecked => _tasks.every((task) => _checked.contains(task));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._tasks.map((task) => CheckboxListTile(
              value: _checked.contains(task),
              title: Text(task),
              onChanged: (val) async {
                setState(() {
                  if (val == true) {
                    if (!_checked.contains(task)) _checked.add(task);
                  } else {
                    _checked.remove(task);
                  }
                });
                // Update ke backend
                await OrderService().updateOrder(
                  widget.order.copyWith(designerWorkChecklist: _checked),
                );
              },
            )),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.send),
          label: const Text('Submit ke Cor'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _allChecked ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: _allChecked
              ? () {
                  widget.onSubmit(_checked);
                }
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          'Checklist sudah sesuai designer',
          style: TextStyle(
            color: _allChecked ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tab sudah sesuai designer',
          style: TextStyle(
            color: _allChecked ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}