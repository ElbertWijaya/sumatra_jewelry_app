import 'package:flutter/material.dart';

class FinisherTaskScreen extends StatelessWidget {
  final bool finishingDone;
  final bool qcFinishingDone;
  final Function(bool, bool) onChanged;
  final bool enabled;

  const FinisherTaskScreen({
    Key? key,
    required this.finishingDone,
    required this.qcFinishingDone,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          value: finishingDone,
          onChanged: enabled ? (v) => onChanged(v ?? false, qcFinishingDone) : null,
          title: const Text('Finishing'),
        ),
        CheckboxListTile(
          value: qcFinishingDone,
          onChanged: enabled ? (v) => onChanged(finishingDone, v ?? false) : null,
          title: const Text('QC Finishing'),
        ),
      ],
    );
  }
}