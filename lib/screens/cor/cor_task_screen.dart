import 'package:flutter/material.dart';

class CorTaskScreen extends StatelessWidget {
  final bool lilinDone;
  final bool corDone;
  final Function(bool lilin, bool cor) onChanged;
  final bool enabled;

  const CorTaskScreen({
    Key? key,
    required this.lilinDone,
    required this.corDone,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          value: lilinDone,
          onChanged: enabled ? (v) => onChanged(v ?? false, corDone) : null,
          title: const Text('Lilin'),
        ),
        CheckboxListTile(
          value: corDone,
          onChanged: enabled ? (v) => onChanged(lilinDone, v ?? false) : null,
          title: const Text('Cor'),
        ),
      ],
    );
  }
}