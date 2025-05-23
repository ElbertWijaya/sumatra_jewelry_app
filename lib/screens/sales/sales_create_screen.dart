import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesCreateScreen extends StatefulWidget {
  const SalesCreateScreen({Key? key}) : super(key: key);

  @override
  State<SalesCreateScreen> createState() => _SalesCreateScreenState();
}

class _SalesCreateScreenState extends State<SalesCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderService = OrderService();

  // Form fields
  String customerName = '';
  String customerContact = '';
  String address = '';
  String jewelryType = '';
  String? stoneType;
  String? stoneSize;
  String? ringSize;
  DateTime? readyDate;
  double? goldPricePerGram;
  String? notes;

  bool _isLoading = false;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final order = Order(
      id: const Uuid().v4(),
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
      workflowStatus: OrderWorkflowStatus.pending,
    );

    try {
      await _orderService.addOrder(order);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!')));
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat pesanan: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan Baru')),
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
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        onSaved: (v) => customerName = v ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        onSaved: (v) => customerContact = v ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Alamat *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        onSaved: (v) => address = v ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Jenis Perhiasan *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        onSaved: (v) => jewelryType = v ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Jenis Batu',
                        ),
                        onSaved: (v) => stoneType = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Batu',
                        ),
                        onSaved: (v) => stoneSize = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Cincin',
                        ),
                        onSaved: (v) => ringSize = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Harga Emas/Gram',
                        ),
                        keyboardType: TextInputType.number,
                        onSaved:
                            (v) => goldPricePerGram = double.tryParse(v ?? ''),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Catatan Tambahan',
                        ),
                        onSaved: (v) => notes = v,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InputDatePickerFormField(
                              fieldLabelText: 'Tanggal Siap',
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 1),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              onDateSaved: (d) => readyDate = d,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitOrder,
                        child: const Text('Simpan Pesanan'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
