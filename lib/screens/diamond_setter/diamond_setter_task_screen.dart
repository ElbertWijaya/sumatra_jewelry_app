import 'package:flutter/material.dart';

class DiamondSetterTaskScreen extends StatelessWidget {
  final bool pasangBatuDone;
  final bool qcBatuDone;
  final Function(bool, bool) onChanged;
  final bool enabled;

  const DiamondSetterTaskScreen({
    Key? key,
    required this.pasangBatuDone,
    required this.qcBatuDone,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          value: pasangBatuDone,
          onChanged: enabled ? (v) => onChanged(v ?? false, qcBatuDone) : null,
          title: const Text('Pasang Batu'),
        ),
        CheckboxListTile(
          value: qcBatuDone,
          onChanged: enabled ? (v) => onChanged(pasangBatuDone, v ?? false) : null,
          title: const Text('QC Pasang Batu'),
        ),
      ],
    );
  }
}