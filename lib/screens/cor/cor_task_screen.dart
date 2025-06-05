import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class CorTaskScreen extends StatefulWidget {
  final Order order;
  final Function(List<String> checklist) onSubmit;
  const CorTaskScreen({super.key, required this.order, required this.onSubmit});
  @override
  State<CorTaskScreen> createState() => _CorTaskScreenState();
}

class _CorTaskScreenState extends State<CorTaskScreen> {
  final List<String> _tasks = ['Casting', 'Pengecekan', 'Serah ke Carver'];
  late List<String> _checked;
  @override
  void initState() {
    super.initState();
    _checked = List<String>.from(widget.order.castingWorkChecklist ?? []);
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
            await OrderService().updateOrder(
              widget.order.copyWith(castingWorkChecklist: _checked),
            );
          },
        )),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.send),
          label: const Text('Submit ke Carver'),
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
      ],
    );
  }
}
