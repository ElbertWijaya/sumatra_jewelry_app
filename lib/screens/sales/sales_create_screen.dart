import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'package:flutter/services.dart';

class SalesCreateScreen extends StatefulWidget {
  const SalesCreateScreen({super.key});

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

  final TextEditingController _dateController = TextEditingController();

  bool _isLoading = false;

  // Image picker
  final List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(images);
      });
    }
  }

  void _removeImage(int idx) {
    setState(() {
      _pickedImages.removeAt(idx);
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

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
      imagePaths:
          _pickedImages
              .map((e) => e.path)
              .toList(), // Anda bisa menambahkan image path ke model Order jika ingin menyimpan rujukan gambar
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
                      // === PILIHAN GAMBAR ===
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Referensi Gambar',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _pickedImages.length + 1,
                          itemBuilder: (context, index) {
                            if (index < _pickedImages.length) {
                              final file = _pickedImages[index];
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(file.path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Container(
                                width: 100,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: OutlinedButton(
                                  onPressed: _pickImages,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 32),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tambah\nGambar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // === FORM FIELD LAINNYA ===
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
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Siap',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: readyDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 1),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              readyDate = picked;
                              _dateController.text =
                                  "${picked.day}/${picked.month}/${picked.year}";
                            });
                          }
                        },
                        validator: (v) => null,
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
