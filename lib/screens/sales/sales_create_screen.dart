import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesCreateScreen extends StatefulWidget {
  const SalesCreateScreen({Key? key}) : super(key: key);

  @override
  State<SalesCreateScreen> createState() => _SalesCreateScreenState();
}

class _SalesCreateScreenState extends State<SalesCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _jewelryTypeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerContactController.dispose();
    _addressController.dispose();
    _jewelryTypeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: _customerNameController.text,
      customerContact: _customerContactController.text,
      address: _addressController.text,
      jewelryType: _jewelryTypeController.text,
      createdAt: DateTime.now(),
      // Tambahkan field lain jika perlu
    );

    try {
      await OrderService().addOrder(order);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil ditambahkan!')),
      );
      Navigator.of(context).pop(true); // Kembali ke list, trigger refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah pesanan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _customerContactController,
                decoration: const InputDecoration(labelText: 'No. Telepon'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _jewelryTypeController,
                decoration: const InputDecoration(labelText: 'Jenis Perhiasan'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Simpan Pesanan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}