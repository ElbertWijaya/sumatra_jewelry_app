import 'package:flutter/material.dart';

class InventoryTaskScreen extends StatelessWidget {
  final TextEditingController kodeBarangController;
  final TextEditingController lokasiRakController;
  final TextEditingController catatanController;
  final bool enabled;

  const InventoryTaskScreen({
    Key? key,
    required this.kodeBarangController,
    required this.lokasiRakController,
    required this.catatanController,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: kodeBarangController,
          decoration: const InputDecoration(
            labelText: 'Kode Barang',
            border: OutlineInputBorder(),
          ),
          enabled: enabled,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: lokasiRakController,
          decoration: const InputDecoration(
            labelText: 'Lokasi Rak',
            border: OutlineInputBorder(),
          ),
          enabled: enabled,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: catatanController,
          decoration: const InputDecoration(
            labelText: 'Catatan Tambahan (Opsional)',
            border: OutlineInputBorder(),
          ),
          enabled: enabled,
          maxLines: 2,
        ),
      ],
    );
  }
}