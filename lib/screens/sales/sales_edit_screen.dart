import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

import '../../models/order.dart';
import '../../utils/thousand_separator_input_formatter.dart';

final _currencyFormatter = NumberFormat.currency(
  locale: 'id',
  symbol: 'Rp ',
  decimalDigits: 0,
);

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
    'Bangle',
    'Ring',
    'Earrings',
    'Necklace',
    'Bracelet',
    'Pendant',
    'Other',
  ];
  final _goldTypes = ['24K', '22K', '18K', '14K', '10K', '9K'];
  final _goldColors = ['White Gold', 'Rose Gold', 'Yellow Gold'];

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    _customerNameController = TextEditingController(text: o.customerName);
    _customerContactController = TextEditingController(text: o.customerContact);
    _addressController = TextEditingController(text: o.address);
    _finalPriceController = TextEditingController(
      text: o.finalPrice.toStringAsFixed(0),
    );
    _notesController = TextEditingController(text: o.notes ?? '');
    _pickupDateController = TextEditingController(
      text:
          o.pickupDate != null
              ? DateFormat('yyyy-MM-dd').format(o.pickupDate!)
              : '',
    );
    _goldPricePerGramController = TextEditingController(
      text: o.goldPricePerGram.toStringAsFixed(0),
    );
    _stoneTypeController = TextEditingController(text: o.stoneType ?? '');
    _stoneSizeController = TextEditingController(text: o.stoneSize ?? '');
    _ringSizeController = TextEditingController(text: o.ringSize ?? '');
    _readyDateController = TextEditingController(
      text:
          o.readyDate != null
              ? DateFormat('yyyy-MM-dd').format(o.readyDate!)
              : '',
    );
    _dpController = TextEditingController(text: o.dp.toStringAsFixed(0));
    _sisaLunasController = TextEditingController(
      text: (o.finalPrice - o.dp).clamp(0, double.infinity).toStringAsFixed(0),
    );
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

  Future<void> _pickPickupDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPickupDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.amber,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedPickupDate = picked;
        _pickupDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickReadyDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedReadyDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.amber,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedReadyDate = picked;
        _readyDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // Upload to server
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.83.117/orders_photo/upload_image.php'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', picked.path),
      );
      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var jsonResp = json.decode(respStr);
        if (jsonResp['success']) {
          setState(() {
            _uploadedImageUrls.add(jsonResp['url']); // URL penuh
            _pickedImages.add(File(picked.path));
          });
        }
      }
    }
  }

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
      finalPrice:
          double.tryParse(_finalPriceController.text.replaceAll('.', '')) ?? 0,
      notes: _notesController.text,
      pickupDate: _selectedPickupDate,
      goldPricePerGram:
          _goldPricePerGramController.text.isNotEmpty
              ? double.tryParse(
                    _goldPricePerGramController.text.replaceAll('.', ''),
                  ) ??
                  0
              : 0,
      stoneType:
          _stoneTypeController.text.isNotEmpty ? _stoneTypeController.text : '',
      stoneSize:
          _stoneSizeController.text.isNotEmpty ? _stoneSizeController.text : '',
      ringSize:
          _ringSizeController.text.isNotEmpty ? _ringSizeController.text : '',
      readyDate: _selectedReadyDate,
      dp:
          _dpController.text.isNotEmpty
              ? double.tryParse(_dpController.text.replaceAll('.', '')) ?? 0
              : 0,
      sisaLunas:
          (double.tryParse(_finalPriceController.text.replaceAll('.', '')) ??
              0) -
          (double.tryParse(_dpController.text.replaceAll('.', '')) ?? 0),
      imagePaths: List<String>.from(_uploadedImageUrls), // <-- PASTIKAN URL
    );

    try {
      // DEBUG: print data yang akan dikirim ke backend
      print('DEBUG order.id: ${order.id}');
      print(
        'DEBUG body: ${{'id': order.id, 'customer_name': order.customerName, 'customer_contact': order.customerContact, 'address': order.address, 'jewelry_type': order.jewelryType, 'gold_type': order.goldType, 'gold_color': order.goldColor, 'final_price': order.finalPrice.toString(), 'notes': order.notes, 'pickup_date': order.pickupDate != null ? DateFormat('yyyy-MM-dd').format(order.pickupDate!) : '', 'gold_price_per_gram': order.goldPricePerGram.toString(), 'stone_type': order.stoneType, 'stone_size': order.stoneSize, 'ring_size': order.ringSize, 'ready_date': order.readyDate != null ? DateFormat('yyyy-MM-dd').format(order.readyDate!) : '', 'dp': order.dp.toString(), 'sisa_lunas': order.sisaLunas.toString(), 'imagePaths': jsonEncode(order.imagePaths)}}',
      );

      final response = await http.post(
        Uri.parse('http://192.168.83.117/sumatra_api/update_order.php'),
        body: {
          'id': order.id,
          'customer_name': order.customerName ?? '',
          'customer_contact': order.customerContact ?? '',
          'address': order.address ?? '',
          'jewelry_type': order.jewelryType ?? '',
          'gold_type': order.goldType ?? '',
          'gold_color': order.goldColor ?? '',
          'final_price': order.finalPrice.toString() ?? '0',
          'notes': order.notes ?? '',
          'pickup_date':
              order.pickupDate != null
                  ? DateFormat('yyyy-MM-dd').format(order.pickupDate!)
                  : '',
          'gold_price_per_gram': order.goldPricePerGram.toString() ?? '0',
          'stone_type': order.stoneType ?? '',
          'stone_size': order.stoneSize ?? '',
          'ring_size': order.ringSize ?? '',
          'ready_date':
              order.readyDate != null
                  ? DateFormat('yyyy-MM-dd').format(order.readyDate!)
                  : '',
          'dp': order.dp.toString() ?? '0',
          'sisa_lunas': order.sisaLunas.toString() ?? '0',
          'imagePaths': jsonEncode(order.imagePaths),
        },
      );
      print('Response: ${response.body}');
      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil diupdate!')),
        );
        Navigator.of(context).pop(true);
      } else {
        // Tampilkan error detail dari backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update pesanan: ${result['error']}')),
        );
        print('Error dari backend: ${result['error']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update pesanan: $e')));
      print('Exception: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _luxuryDecoration(
    String label, {
    bool required = false,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: required ? "$label *" : label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.amber[700]) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.amber[50],
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  double get _finalPrice =>
      double.tryParse(_finalPriceController.text.replaceAll('.', '')) ?? 0;
  double get _dp =>
      double.tryParse(_dpController.text.replaceAll('.', '')) ?? 0;
  double get _sisaLunas => (_finalPrice - _dp).clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pesanan'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- INFORMASI PELANGGAN ---
              const Text(
                'Informasi Pelanggan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              TextFormField(
                controller: _customerNameController,
                decoration: _luxuryDecoration(
                  'Nama Pelanggan',
                  required: true,
                  icon: Icons.person,
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerContactController,
                decoration: _luxuryDecoration(
                  'No. Telepon',
                  required: true,
                  icon: Icons.phone,
                ),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: _luxuryDecoration(
                  'Alamat',
                  required: true,
                  icon: Icons.location_on,
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 24),

              // --- INFORMASI BARANG ---
              const Text(
                'Informasi Barang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              DropdownButtonFormField<String>(
                value: _selectedJewelryType,
                isDense: true,
                decoration: _luxuryDecoration(
                  'Jenis Perhiasan',
                  required: true,
                  icon: Icons.star,
                ),
                items:
                    _jewelryTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedJewelryType = val),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGoldType,
                isDense: true,
                decoration: _luxuryDecoration(
                  'Jenis Emas',
                  required: true,
                  icon: Icons.grade,
                ),
                items:
                    _goldTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedGoldType = val),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGoldColor,
                isDense: true,
                decoration: _luxuryDecoration(
                  'Warna Emas',
                  required: true,
                  icon: Icons.color_lens,
                ),
                items:
                    _goldColors
                        .map(
                          (color) => DropdownMenuItem(
                            value: color,
                            child: Text(
                              color,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedGoldColor = val),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ringSizeController,
                decoration: _luxuryDecoration(
                  'Ukuran Cincin',
                  icon: Icons.ring_volume,
                ),
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
              const Text(
                'Informasi Harga',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              TextFormField(
                controller: _finalPriceController,
                decoration: _luxuryDecoration(
                  'Harga Perkiraan',
                  required: true,
                  icon: Icons.attach_money,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                inputFormatters: [ThousandSeparatorInputFormatter()],
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _goldPricePerGramController,
                decoration: _luxuryDecoration(
                  'Harga Emas per Gram',
                  icon: Icons.scale,
                ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- INFORMASI TANGGAL ---
              const Text(
                'Informasi Tanggal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              GestureDetector(
                onTap: _pickPickupDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _pickupDateController,
                    decoration: _luxuryDecoration(
                      'Tanggal Ambil',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickReadyDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _readyDateController,
                    decoration: _luxuryDecoration(
                      'Tanggal Jadi',
                      icon: Icons.event_available,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- INFORMASI TAMBAHAN (opsional) ---
              const Text(
                'Informasi Tambahan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(
                'Referensi Gambar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._pickedImages.map(
                      (img) => GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => Dialog(
                                  child: SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: PhotoView(
                                      imageProvider: FileImage(img),
                                      backgroundDecoration: const BoxDecoration(
                                        color: Colors.black,
                                      ),
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
                      ),
                    ),
                    // PATCH: preview gambar yang sudah (lama) dari server
                    ..._uploadedImageUrls
                        .where(
                          (url) =>
                              url.isNotEmpty &&
                              !_pickedImages.any((file) => file.path == url),
                        )
                        .map((img) {
                          final String imageUrl =
                              img.startsWith('http')
                                  ? img
                                  : 'http://192.168.83.117/sumatra_api/$img';
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }),
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
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.amber,
                          size: 32,
                        ),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText:
                            'Tulis permintaan khusus atau catatan di sini...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      maxLines: 3,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Wajib diisi'
                                  : null,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const Icon(Icons.save),
                    onPressed: _submit,
                    label: const Text('Simpan Perubahan'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
