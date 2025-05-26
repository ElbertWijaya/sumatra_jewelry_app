import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesCreateScreen extends StatefulWidget {
  const SalesCreateScreen({super.key});

  @override
  State<SalesCreateScreen> createState() => _SalesCreateScreenState();
}

class _SalesCreateScreenState extends State<SalesCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _stoneSizeController = TextEditingController();
  final _ringSizeController = TextEditingController();
  final _notesController = TextEditingController();
  final _goldPriceController = TextEditingController();

  String? _jewelryType;
  String? _goldColor;
  String? _goldType;
  String? _stoneType;
  DateTime? _readyDate;
  final List<String> _images = [];

  bool _isSaving = false;

  final List<String> jewelryTypes = [
    "ring",
    "bangle",
    "earring",
    "pendant",
    "hairpin",
    "pin",
    "men ring",
    "women ring",
    "engagement ring",
    "custom",
  ];
  final List<String> goldColors = ["White Gold", "Rose Gold", "Yellow Gold"];
  final List<String> goldTypes = ["19K", "18K", "14K", "9K"];
  final List<String> stoneTypes = [
    "Opal",
    "Sapphire",
    "Jade",
    "Emerald",
    "Ruby",
    "Amethyst",
    "Diamond",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _stoneSizeController.dispose();
    _ringSizeController.dispose();
    _notesController.dispose();
    _goldPriceController.dispose();
    super.dispose();
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: _nameController.text,
      customerContact: _contactController.text,
      address: _addressController.text,
      jewelryType: _jewelryType ?? "",
      goldColor: _goldColor,
      goldType: _goldType,
      stoneType: _stoneType,
      stoneSize:
          _stoneSizeController.text.isEmpty ? null : _stoneSizeController.text,
      ringSize:
          _ringSizeController.text.isEmpty ? null : _ringSizeController.text,
      goldPricePerGram: double.tryParse(_goldPriceController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      readyDate: _readyDate,
      imagePaths: _images,
      workflowStatus: OrderWorkflowStatus.waiting_sales_check,
      createdAt: DateTime.now(),
    );

    try {
      await OrderService().addOrder(order);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat pesanan: $e')));
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan')),
      body:
          _isSaving
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon *',
                        ),
                        keyboardType: TextInputType.phone,
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _jewelryType,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Perhiasan *',
                        ),
                        items:
                            jewelryTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Pilih salah satu'
                                    : null,
                        onChanged: (val) => setState(() => _jewelryType = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _goldColor,
                        decoration: const InputDecoration(
                          labelText: 'Warna Emas',
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('-')),
                          ...goldColors
                              .map(
                                (color) => DropdownMenuItem(
                                  value: color,
                                  child: Text(color),
                                ),
                              )
                              ,
                        ],
                        onChanged: (val) => setState(() => _goldColor = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _goldType,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Emas',
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('-')),
                          ...goldTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              ,
                        ],
                        onChanged: (val) => setState(() => _goldType = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _stoneType,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Batu',
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('-')),
                          ...stoneTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              ,
                        ],
                        onChanged: (val) => setState(() => _stoneType = val),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _stoneSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Batu',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ringSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Cincin',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _goldPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Emas/Gram',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Tambahan',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _readyDate == null
                                  ? 'Tanggal Siap (opsional)'
                                  : 'Tanggal Siap: ${_readyDate?.day}/${_readyDate?.month}/${_readyDate?.year}',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _readyDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  _readyDate = picked;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      // Gambar bisa kamu tambahkan di sini (opsional)
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveOrder,
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
