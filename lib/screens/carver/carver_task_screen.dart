import 'package:flutter/material.dart';

class CarverTaskScreen extends StatelessWidget {
  final bool ukirDone;
  final bool qcUkirDone;
  final Function(bool, bool) onChanged;
  final bool enabled;

  const CarverTaskScreen({
    Key? key,
    required this.ukirDone,
    required this.qcUkirDone,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          value: ukirDone,
          onChanged: enabled ? (v) => onChanged(v ?? false, qcUkirDone) : null,
          title: const Text('Ukir'),
        ),
        CheckboxListTile(
          value: qcUkirDone,
          onChanged: enabled ? (v) => onChanged(ukirDone, v ?? false) : null,
          title: const Text('QC Ukir'),
        ),
      ],
    );
  }
}