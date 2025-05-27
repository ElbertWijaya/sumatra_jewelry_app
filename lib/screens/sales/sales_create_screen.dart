import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/order.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../../services/order_service.dart';

class SalesCreateScreen extends StatefulWidget {
  const SalesCreateScreen({super.key});

  @override
  State<SalesCreateScreen> createState() => _SalesCreateScreenState();
}

class _SalesCreateScreenState extends State<SalesCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stoneSizeController = TextEditingController();
  final TextEditingController _ringSizeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _dpController = TextEditingController();

  String? _jewelryType;
  String? _goldColor;
  String? _goldType;
  String? _stoneType;
  DateTime? _readyDate;
  List<String> _images = [];
  bool _isSaving = false;

  double get _hargaBarang {
    return double.tryParse(
          toNumericString(_hargaController.text, allowPeriod: false),
        ) ??
        0;
  }

  double get _dp {
    return double.tryParse(
          toNumericString(_dpController.text, allowPeriod: false),
        ) ??
        0;
  }

  double get _sisaLunas {
    final harga = _hargaBarang;
    final dp = _dp;
    final sisa = harga - dp;
    return sisa < 0 ? 0 : sisa;
  }

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

  final _rupiahFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _stoneSizeController.dispose();
    _ringSizeController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _hargaController.dispose();
    _dpController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (!mounted) return;
      if (images.isNotEmpty) {
        setState(() {
          _images.addAll(images.map((x) => x.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  void _removeImage(int idx) {
    setState(() {
      _images.removeAt(idx);
    });
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: _nameController.text,
      customerContact: _contactController.text,
      address: _addressController.text,
      jewelryType: _jewelryType ?? '',
      goldColor: _goldColor,
      goldType: _goldType,
      stoneType: _stoneType,
      stoneSize:
          _stoneSizeController.text.isEmpty ? null : _stoneSizeController.text,
      ringSize:
          _ringSizeController.text.isEmpty ? null : _ringSizeController.text,
      goldPricePerGram: null,
      finalPrice: _hargaBarang,
      dp: _dp,
      sisaLunas: _sisaLunas,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      readyDate: _readyDate,
      imagePaths: _images,
      workflowStatus: OrderWorkflowStatus.waitingSalesCheck,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await OrderService().addOrder(order);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat pesanan: $e')));
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan Baru')),
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
                      // Nama Pelanggan
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan *',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      // Nomor Telepon
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon *',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nomor telepon wajib diisi';
                          }
                          if (v.length < 8) {
                            return 'Nomor telepon minimal 8 digit';
                          }
                          return null;
                        },
                      ),
                      // Alamat
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat *',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Alamat wajib diisi';
                          }
                          return null;
                        },
                      ),
                      // Jenis Perhiasan
                      DropdownButtonFormField<String>(
                        value: _jewelryType,
                        items:
                            jewelryTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _jewelryType = v),
                        decoration: const InputDecoration(
                          labelText: 'Jenis Perhiasan *',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Pilih jenis perhiasan';
                          }
                          return null;
                        },
                      ),
                      // Warna Emas
                      DropdownButtonFormField<String>(
                        value: _goldColor,
                        items:
                            goldColors
                                .map(
                                  (color) => DropdownMenuItem(
                                    value: color,
                                    child: Text(color),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _goldColor = v),
                        decoration: const InputDecoration(
                          labelText: 'Warna Emas *',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Pilih warna emas';
                          }
                          return null;
                        },
                      ),
                      // Jenis Emas
                      DropdownButtonFormField<String>(
                        value: _goldType,
                        items:
                            goldTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _goldType = v),
                        decoration: const InputDecoration(
                          labelText: 'Jenis Emas *',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Pilih jenis emas';
                          }
                          return null;
                        },
                      ),
                      // Jenis Batu
                      DropdownButtonFormField<String>(
                        value: _stoneType,
                        items:
                            stoneTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _stoneType = v),
                        decoration: const InputDecoration(
                          labelText: 'Jenis Batu',
                        ),
                      ),
                      // Ukuran Batu
                      TextFormField(
                        controller: _stoneSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Batu',
                        ),
                      ),
                      // Ukuran Cincin
                      TextFormField(
                        controller: _ringSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Cincin',
                        ),
                      ),
                      // Harga Barang / Perkiraan
                      TextFormField(
                        controller: _hargaController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Barang / Perkiraan *',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyInputFormatter(
                            thousandSeparator: ThousandSeparator.Period,
                            mantissaLength: 0,
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Harga wajib diisi';
                          }
                          if (toNumericString(v, allowPeriod: false).isEmpty) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      // Jumlah DP
                      TextFormField(
                        controller: _dpController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah DP',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyInputFormatter(
                            thousandSeparator: ThousandSeparator.Period,
                            mantissaLength: 0,
                          ),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                      // Sisa harga untuk lunas (readonly)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Text(
                              'Sisa harga untuk lunas: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _rupiahFormat.format(_sisaLunas),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Catatan Tambahan sebagai notes besar (multiline)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Catatan Tambahan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber,
                                  width: 1,
                                ),
                              ),
                              child: TextFormField(
                                controller: _notesController,
                                maxLines: 6,
                                minLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Tulis catatan tambahan di sini...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tanggal Siap
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Siap',
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _readyDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 2),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              _readyDate = picked;
                              _dateController.text =
                                  "${picked.day}/${picked.month}/${picked.year}";
                            });
                          }
                        },
                      ),
                      // Gambar referensi
                      const SizedBox(height: 12),
                      Text(
                        'Gambar Referensi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length + 1,
                          itemBuilder: (context, idx) {
                            if (idx == _images.length) {
                              return GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_images[idx]),
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (c, e, s) => Container(
                                            width: 110,
                                            height: 110,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.broken_image,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(idx),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveOrder,
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Simpan Pesanan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
