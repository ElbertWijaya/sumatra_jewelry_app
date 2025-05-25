import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesEditScreen extends StatefulWidget {
  const SalesEditScreen({super.key});

  @override
  State<SalesEditScreen> createState() => _SalesEditScreenState();
}

class _SalesEditScreenState extends State<SalesEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderService = OrderService();

  late Order order;
  bool _isLoading = false;

  // Form fields
  late String customerName;
  late String customerContact;
  late String address;
  late String jewelryType;
  String? stoneType;
  String? stoneSize;
  String? ringSize;
  DateTime? readyDate;
  double? goldPricePerGram;
  String? notes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Order? argOrder =
        ModalRoute.of(context)?.settings.arguments as Order?;
    if (argOrder != null && (order.id != argOrder.id)) {
      order = argOrder;
      customerName = order.customerName;
      customerContact = order.customerContact;
      address = order.address;
      jewelryType = order.jewelryType;
      stoneType = order.stoneType;
      stoneSize = order.stoneSize;
      ringSize = order.ringSize;
      readyDate = order.readyDate;
      goldPricePerGram = order.goldPricePerGram;
      notes = order.notes;
    }
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final updatedOrder = order.copyWith(
      customerName: customerName,
      customerContact: customerContact,
      address: address,
      jewelryType: jewelryType,
      stoneType: stoneType,
      stoneSize: stoneSize,
      ringSize: ringSize,
      readyDate: readyDate,
      goldPricePerGram: goldPricePerGram,
      notes: notes,
      updatedAt: DateTime.now(),
      // workflowStatus tidak diubah di sini oleh sales
    );

    try {
      await _orderService.updateOrder(updatedOrder);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil diperbarui!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui pesanan: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pesanan')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: customerName,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        onSaved: (v) => customerName = v ?? '',
                      ),
                      TextFormField(
                        initialValue: customerContact,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        onSaved: (v) => customerContact = v ?? '',
                      ),
                      TextFormField(
                        initialValue: address,
                        decoration: const InputDecoration(
                          labelText: 'Alamat *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        onSaved: (v) => address = v ?? '',
                      ),
                      TextFormField(
                        initialValue: jewelryType,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Perhiasan *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        onSaved: (v) => jewelryType = v ?? '',
                      ),
                      TextFormField(
                        initialValue: stoneType,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Batu',
                        ),
                        onSaved: (v) => stoneType = v,
                      ),
                      TextFormField(
                        initialValue: stoneSize,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Batu',
                        ),
                        onSaved: (v) => stoneSize = v,
                      ),
                      TextFormField(
                        initialValue: ringSize,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Cincin',
                        ),
                        onSaved: (v) => ringSize = v,
                      ),
                      TextFormField(
                        initialValue: goldPricePerGram?.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Harga Emas/Gram',
                        ),
                        keyboardType: TextInputType.number,
                        onSaved:
                            (v) => goldPricePerGram = double.tryParse(v ?? ''),
                      ),
                      TextFormField(
                        initialValue: notes,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Tambahan',
                        ),
                        onSaved: (v) => notes = v,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitEdit,
                        child: const Text('Simpan Perubahan'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
