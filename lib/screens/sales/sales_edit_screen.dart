import 'package:flutter/material.dart';
import '../../models/order.dart';

class SalesEditScreen extends StatefulWidget {
  final Order order;
  const SalesEditScreen({super.key, required this.order});

  @override
  State<SalesEditScreen> createState() => _SalesEditScreenState();
}

class _SalesEditScreenState extends State<SalesEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.order.customerName);
    _contactController = TextEditingController(text: widget.order.customerContact);
    _addressController = TextEditingController(text: widget.order.address);
    _notesController = TextEditingController(text: widget.order.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: _contactController, decoration: const InputDecoration(labelText: 'Kontak')),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Alamat')),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Catatan')),
            // Tambahkan field lain sesuai kebutuhan
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Simpan perubahan ke backend
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}