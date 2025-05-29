import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

import '../../models/order.dart';
import '../../utils/thousand_separator_input_formatter.dart';

final _currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

class SalesEditScreen extends StatefulWidget {
  final Order order;
  const SalesEditScreen({super.key, required this.order});

  @override
  State<SalesEditScreen> createState() => _SalesEditScreenState();
}

class _SalesEditScreenState extends State<SalesEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _customerContactController;
  late TextEditingController _addressController;
  late TextEditingController _finalPriceController;
  late TextEditingController _notesController;
  late TextEditingController _pickupDateController;
  late TextEditingController _goldPricePerGramController;
  late TextEditingController _stoneTypeController;
  late TextEditingController _stoneSizeController;
  late TextEditingController _ringSizeController;
  late TextEditingController _readyDateController;
  late TextEditingController _dpController;
  late TextEditingController _sisaLunasController;

  String? _selectedJewelryType;
  String? _selectedGoldType;
  String? _selectedGoldColor;
  DateTime? _selectedPickupDate;
  DateTime? _selectedReadyDate;
  bool _isLoading = false;
  final List<File> _pickedImages = [];
  List<String> _uploadedImageUrls = [];

  final _jewelryTypes = [
    'Bangle', 'Ring', 'Earrings', 'Necklace', 'Bracelet', 'Pendant', 'Other'
  ];
  final _goldTypes = [
    '24k', '22k', '18k', '14k', '9k'
  ];
  final _goldColors = [
    'White Gold', 'Rose Gold', 'Yellow Gold'
  ];

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    _customerNameController = TextEditingController(text: o.customerName);
    _customerContactController = TextEditingController(text: o.customerContact);
    _addressController = TextEditingController(text: o.address);
    _finalPriceController = TextEditingController(text: o.finalPrice.toStringAsFixed(0));
    _notesController = TextEditingController(text: o.notes ?? '');
    _pickupDateController = TextEditingController(
      text: o.pickupDate != null ? DateFormat('yyyy-MM-dd').format(o.pickupDate!) : '',
    );
    _goldPricePerGramController = TextEditingController(text: o.goldPricePerGram.toStringAsFixed(0));
    _stoneTypeController = TextEditingController(text: o.stoneType ?? '');
    _stoneSizeController = TextEditingController(text: o.stoneSize ?? '');
    _ringSizeController = TextEditingController(text: o.ringSize ?? '');
    _readyDateController = TextEditingController(
      text: o.readyDate != null ? DateFormat('yyyy-MM-dd').format(o.readyDate!) : '',
    );
    _dpController = TextEditingController(text: o.dp.toStringAsFixed(0));
    _sisaLunasController = TextEditingController(text: (o.finalPrice - o.dp).clamp(0, double.infinity).toStringAsFixed(0));
    _selectedJewelryType = o.jewelryType;
    _selectedGoldType = o.goldType;
    _selectedGoldColor = o.goldColor;
    _selectedPickupDate = o.pickupDate;
    _selectedReadyDate = o.readyDate;
    _uploadedImageUrls = List<String>.from(o.imagePaths ?? []);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerContactController.dispose();
    _addressController.dispose();
    _finalPriceController.dispose();
    _notesController.dispose();
    _pickupDateController.dispose();
    _goldPricePerGramController.dispose();
    _stoneTypeController.dispose();
    _stoneSizeController.dispose();
    _ringSizeController.dispose();
    _readyDateController.dispose();
    _dpController.dispose();
    _sisaLunasController.dispose();
    super.dispose();
  }

  // ...fungsi _pickPickupDate, _pickReadyDate, _pickImage sama seperti create...

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final order = widget.order.copyWith(
      customerName: _customerNameController.text,
      customerContact: _customerContactController.text,
      address: _addressController.text,
      jewelryType: _selectedJewelryType ?? '',
      goldType: _selectedGoldType ?? '',
      goldColor: _selectedGoldColor ?? '',
      finalPrice: double.tryParse(_finalPriceController.text.replaceAll('.', '')) ?? 0,
      notes: _notesController.text,
      pickupDate: _selectedPickupDate,
      goldPricePerGram: _goldPricePerGramController.text.isNotEmpty
          ? double.tryParse(_goldPricePerGramController.text.replaceAll('.', '')) ?? 0
          : 0,
      stoneType: _stoneTypeController.text.isNotEmpty ? _stoneTypeController.text : '',
      stoneSize: _stoneSizeController.text.isNotEmpty ? _stoneSizeController.text : '',
      ringSize: _ringSizeController.text.isNotEmpty ? _ringSizeController.text : '',
      readyDate: _selectedReadyDate,
      dp: _dpController.text.isNotEmpty
          ? double.tryParse(_dpController.text.replaceAll('.', '')) ?? 0
          : 0,
      sisaLunas: 
        (double.tryParse(_finalPriceController.text.replaceAll('.', '')) ?? 0) -
        (double.tryParse(_dpController.text.replaceAll('.', '')) ?? 0),
      imagePaths: [..._uploadedImageUrls],
    );

    try {
      final response = await http.post(
        Uri.parse('http://192.168.176.165/sumatra_api/update_order.php'), // Ganti dengan endpoint update
        body: {
          'id': order.id,
          'customer_name': order.customerName,
          'customer_contact': order.customerContact,
          'address': order.address,
          'jewelry_type': order.jewelryType,
          'gold_type': order.goldType,
          'gold_color': order.goldColor,
          'final_price': order.finalPrice.toString() ?? '',
          'notes': order.notes,
          'pickup_date': order.pickupDate != null ? DateFormat('yyyy-MM-dd').format(order.pickupDate!) : '',
          'gold_price_per_gram': order.goldPricePerGram.toString() ?? '',
          'stone_type': order.stoneType ?? '',
          'stone_size': order.stoneSize ?? '',
          'ring_size': order.ringSize ?? '',
          'ready_date': order.readyDate != null ? DateFormat('yyyy-MM-dd').format(order.readyDate!) : '',
          'dp': order.dp.toString() ?? '',
          'sisa_lunas': order.sisaLunas.toString() ?? '',
          'imagePaths': jsonEncode(order.imagePaths),
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil diupdate!')),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Gagal update pesanan: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update pesanan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pesanan'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nama
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Customer',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      // Kontak
                      TextFormField(
                        controller: _customerContactController,
                        decoration: const InputDecoration(
                          labelText: 'Kontak',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      // Alamat
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      // Jenis Perhiasan
                      DropdownButtonFormField<String>(
                        value: _selectedJewelryType,
                        items: _jewelryTypes
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedJewelryType = v),
                        decoration: const InputDecoration(
                          labelText: 'Jenis Perhiasan',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
                      ),
                      const SizedBox(height: 12),
                      // Jenis Emas
                      DropdownButtonFormField<String>(
                        value: _selectedGoldType,
                        items: _goldTypes
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedGoldType = v),
                        decoration: const InputDecoration(
                          labelText: 'Jenis Emas',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
                      ),
                      const SizedBox(height: 12),
                      // Warna Emas
                      DropdownButtonFormField<String>(
                        value: _selectedGoldColor,
                        items: _goldColors
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedGoldColor = v),
                        decoration: const InputDecoration(
                          labelText: 'Warna Emas',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
                      ),
                      const SizedBox(height: 12),
                      // Harga Akhir
                      TextFormField(
                        controller: _finalPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Akhir',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [ThousandSeparatorInputFormatter()],
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      // DP
                      TextFormField(
                        controller: _dpController,
                        decoration: const InputDecoration(
                          labelText: 'DP',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [ThousandSeparatorInputFormatter()],
                      ),
                      const SizedBox(height: 12),
                      // Sisa Lunas (readonly)
                      TextFormField(
                        controller: _sisaLunasController,
                        decoration: const InputDecoration(
                          labelText: 'Sisa Lunas',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),
                      // Harga Emas per Gram
                      TextFormField(
                        controller: _goldPricePerGramController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Emas per Gram',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [ThousandSeparatorInputFormatter()],
                      ),
                      const SizedBox(height: 12),
                      // Tipe Batu
                      TextFormField(
                        controller: _stoneTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Tipe Batu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Ukuran Batu
                      TextFormField(
                        controller: _stoneSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Batu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Ukuran Cincin
                      TextFormField(
                        controller: _ringSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Cincin',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tanggal Ambil
                      TextFormField(
                        controller: _pickupDateController,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Ambil',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedPickupDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedPickupDate = picked;
                              _pickupDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // Tanggal Jadi
                      TextFormField(
                        controller: _readyDateController,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Jadi',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedReadyDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedReadyDate = picked;
                              _readyDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // Catatan
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      // Tombol Simpan
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            );
}
}