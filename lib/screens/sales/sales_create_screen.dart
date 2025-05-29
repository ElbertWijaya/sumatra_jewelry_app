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

class SalesCreateScreen extends StatefulWidget {
  const SalesCreateScreen({super.key});

  @override
  State<SalesCreateScreen> createState() => _SalesCreateScreenState();
}

class _SalesCreateScreenState extends State<SalesCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _finalPriceController = TextEditingController();
  final _notesController = TextEditingController();
  final _pickupDateController = TextEditingController();
  final _goldPricePerGramController = TextEditingController();
  final _stoneTypeController = TextEditingController();
  final _stoneSizeController = TextEditingController();
  final _ringSizeController = TextEditingController();
  final _readyDateController = TextEditingController();
  final _dpController = TextEditingController();
  final _sisaLunasController = TextEditingController();

  String? _selectedJewelryType;
  String? _selectedGoldType;
  String? _selectedGoldColor;
  DateTime? _selectedPickupDate;
  DateTime? _selectedReadyDate;
  bool _isLoading = false;
  final List<File> _pickedImages = [];
  final List<String> _uploadedImageUrls = [];

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

  Future<void> _pickPickupDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPickupDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.amber,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedPickupDate = picked;
        _pickupDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickReadyDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedReadyDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.amber,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedReadyDate = picked;
        _readyDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // Upload ke server
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.176.165/sumatra_api/uploads/upload_image.php'), // Ganti dengan URL server kamu
      );
      request.files.add(await http.MultipartFile.fromPath('image', picked.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        print('Upload response: $respStr');
        var jsonResp = json.decode(respStr);
        if (jsonResp['success']) {
          setState(() {
            _uploadedImageUrls.add(jsonResp['url']);
            _pickedImages.add(File(picked.path));
          });
        }
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: _customerNameController.text,
      customerContact: _customerContactController.text,
      address: _addressController.text,
      jewelryType: _selectedJewelryType ?? '',
      goldType: _selectedGoldType ?? '',
      goldColor: _selectedGoldColor ?? '',
      finalPrice: double.tryParse(_finalPriceController.text.replaceAll('.', '')) ?? 0,
      notes: _notesController.text,
      pickupDate: _selectedPickupDate,
      createdAt: DateTime.now(),
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
      sisaLunas: _sisaLunas,
      imagePaths: _uploadedImageUrls,

    );

    try {
      print('ImagePaths yang dikirim: ${jsonEncode(_uploadedImageUrls)}');
      final response = await http.post(
        Uri.parse('http://192.168.176.165/sumatra_api/add_orders.php'),
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
          'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(order.createdAt),
          'gold_price_per_gram': order.goldPricePerGram.toString() ?? '',
          'stone_type': order.stoneType ?? '',
          'stone_size': order.stoneSize ?? '',
          'ring_size': order.ringSize ?? '',
          'ready_date': order.readyDate != null ? DateFormat('yyyy-MM-dd').format(order.readyDate!) : '',
          'dp': order.dp.toString() ?? '',
          'sisa_lunas': order.sisaLunas.toString() ?? '',
          'imagePaths': jsonEncode(_uploadedImageUrls),
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil ditambahkan!')),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Gagal menambah pesanan: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah pesanan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _luxuryDecoration(String label, {bool required = false, IconData? icon}) {
    return InputDecoration(
      labelText: required ? "$label *" : label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.amber[700]) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.amber[50],
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  double get _finalPrice => double.tryParse(_finalPriceController.text.replaceAll('.', '')) ?? 0;
  double get _dp => double.tryParse(_dpController.text.replaceAll('.', '')) ?? 0;
  double get _sisaLunas => (_finalPrice - _dp).clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pesanan'),
        backgroundColor: Colors.amber[700],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- INFORMASI PELANGGAN ---
              const Text('Informasi Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              TextFormField(
                controller: _customerNameController,
                decoration: _luxuryDecoration('Nama Pelanggan', required: true, icon: Icons.person),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerContactController,
                decoration: _luxuryDecoration('No. Telepon', required: true, icon: Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: _luxuryDecoration('Alamat', required: true, icon: Icons.location_on),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 24),

              // --- INFORMASI BARANG ---
              const Text('Informasi Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              DropdownButtonFormField<String>(
                value: _selectedJewelryType,
                isDense: true,
                decoration: _luxuryDecoration('Jenis Perhiasan', required: true, icon: Icons.star),
                items: _jewelryTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 15))))
                    .toList(),
                onChanged: (val) => setState(() => _selectedJewelryType = val),
                validator: (value) => value == null || value.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGoldType,
                isDense: true,
                decoration: _luxuryDecoration('Jenis Emas', required: true, icon: Icons.grade),
                items: _goldTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 15))))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGoldType = val),
                validator: (value) => value == null || value.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGoldColor,
                isDense: true,
                decoration: _luxuryDecoration('Warna Emas', required: true, icon: Icons.color_lens),
                items: _goldColors
                    .map((color) => DropdownMenuItem(value: color, child: Text(color, style: const TextStyle(fontSize: 15))))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGoldColor = val),
                validator: (value) => value == null || value.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ringSizeController,
                decoration: _luxuryDecoration('Ukuran Cincin', icon: Icons.ring_volume),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stoneTypeController,
                decoration: _luxuryDecoration('Tipe Batu'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stoneSizeController,
                decoration: _luxuryDecoration('Ukuran Batu'),
              ),

              const SizedBox(height: 24),

              // --- INFORMASI HARGA ---
              const Text('Informasi Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              TextFormField(
                controller: _finalPriceController,
                decoration: _luxuryDecoration('Harga Perkiraan', required: true, icon: Icons.attach_money),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                inputFormatters: [ThousandSeparatorInputFormatter()],
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _goldPricePerGramController,
                decoration: _luxuryDecoration('Harga Emas per Gram', icon: Icons.scale),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandSeparatorInputFormatter()],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dpController,
                decoration: _luxuryDecoration('DP', icon: Icons.payments),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                inputFormatters: [ThousandSeparatorInputFormatter()],
              ),
              const SizedBox(height: 12),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Text(
                  'Sisa Lunas: ${_currencyFormatter.format(_sisaLunas)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),
                ),
              ),

              const SizedBox(height: 24),

              // --- INFORMASI TANGGAL ---
              const Text('Informasi Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              GestureDetector(
                onTap: _pickPickupDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _pickupDateController,
                    decoration: _luxuryDecoration('Tanggal Ambil', icon: Icons.calendar_today),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickReadyDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _readyDateController,
                    decoration: _luxuryDecoration('Tanggal Jadi', icon: Icons.event_available),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- INFORMASI TAMBAHAN (opsional) ---
              const Text('Informasi Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Referensi Gambar', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._pickedImages.map((img) => GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: PhotoView(
                                imageProvider: FileImage(img),
                                backgroundDecoration: const BoxDecoration(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber),
                          image: DecorationImage(
                            image: FileImage(img),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: const Icon(Icons.add_a_photo, color: Colors.amber, size: 32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Catatan (memo)
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.edit_note, color: Colors.amber, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Catatan (Memo)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Tulis permintaan khusus atau catatan di sini...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      icon: const Icon(Icons.save),
                      onPressed: _submit,
                      label: const Text('Simpan Pesanan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }  
}
