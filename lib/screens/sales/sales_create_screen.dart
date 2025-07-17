import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class StoneInput {
  String? shape;
  final TextEditingController countController = TextEditingController();
  final TextEditingController caratController = TextEditingController();
  void dispose() {
    countController.dispose();
    caratController.dispose();
  }
}

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
  final _ringSizeController = TextEditingController();
  final _goldPricePerGramController = TextEditingController();
  final _finalPriceController = TextEditingController();
  final _dpController = TextEditingController();
  final _notesController = TextEditingController();
  final _readyDateController = TextEditingController();
  final _pickupDateController = TextEditingController();
  final List<StoneInput> _stoneInputs = [];
  final List<File> _pickedImages = [];
  final List<String> _uploadedImageUrls = [];

  String? _selectedJewelryType;
  String? _selectedGoldType;
  String? _selectedGoldColor;
  DateTime? _selectedReadyDate;
  DateTime? _selectedPickupDate;
  bool _isLoading = false;

  final _jewelryTypes = [
    'Ring',
    'Women Ring',
    'Men Ring',
    'Bangle',
    'Earrings',
    'Necklace',
    'Bracelet',
    'Pendant',
    'Other',
  ];
  final _goldTypes = ['24K', '22K', '18K', '14K', '10K', '9K'];
  final _goldColors = ['White Gold', 'Rose Gold', 'Yellow Gold'];
  final _stoneShapes = [
    'Round',
    'Oval',
    'Princess',
    'Emerald',
    'Pear',
    'Marquise',
    'Cushion',
    'Asscher',
    'Radiant',
    'Heart',
    'Other',
  ];

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerContactController.dispose();
    _addressController.dispose();
    _ringSizeController.dispose();
    _goldPricePerGramController.dispose();
    _finalPriceController.dispose();
    _dpController.dispose();
    _notesController.dispose();
    _readyDateController.dispose();
    _pickupDateController.dispose();
    for (final input in _stoneInputs) {
      input.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(
    TextEditingController controller,
    DateTime? initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate:
          (initial != null && initial.isAfter(today)) ? initial : today,
      firstDate: today,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
      onPicked(picked);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    setState(() {
      _pickedImages.addAll(picked.map((x) => File(x.path)));
    });
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

  void _removeImage(int idx) {
    setState(() {
      _pickedImages.removeAt(idx);
    });
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.83.54/sumatra_api/upload_image.php'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      var response = await request.send().timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var jsonResp = jsonDecode(respStr);
        if (jsonResp['success'] == true) {
          return jsonResp['url'];
        }
      }
    } catch (e) {
      // print(e);
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal 1 gambar referensi wajib diupload.'),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    // Upload gambar ke server dan simpan URL-nya
    _uploadedImageUrls.clear();
    for (final file in _pickedImages) {
      final url = await uploadImage(file);
      if (url != null) {
        _uploadedImageUrls.add(url);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal upload salah satu gambar. Pastikan koneksi stabil dan file tidak terlalu besar.',
            ),
          ),
        );
        return;
      }
    }

    final List<Map<String, String>> stoneUsedList =
        _stoneInputs
            .where(
              (input) =>
                  (input.shape != null && input.shape!.isNotEmpty) ||
                  input.countController.text.isNotEmpty ||
                  input.caratController.text.isNotEmpty,
            )
            .map(
              (input) => {
                'shape': input.shape ?? '',
                'count': input.countController.text,
                'carat': input.caratController.text,
              },
            )
            .toList();

    final now = DateTime.now();
    final ordersId = now.millisecondsSinceEpoch.toString();
    final createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.83.54/sumatra_api/add_orders.php'),
        body: {
          'orders_id': ordersId,
          'orders_customer_name': _customerNameController.text,
          'orders_customer_contact': _customerContactController.text,
          'orders_address': _addressController.text,
          'orders_jewelry_type': _selectedJewelryType ?? '',
          'orders_gold_color': _selectedGoldColor ?? '',
          'orders_gold_type': _selectedGoldType ?? '',
          'orders_ring_size': _ringSizeController.text,
          'orders_stone_used':
              stoneUsedList.isNotEmpty ? jsonEncode(stoneUsedList) : '',
          'orders_ready_date':
              _readyDateController.text.isEmpty
                  ? ''
                  : _readyDateController.text,
          'orders_pickup_date':
              _pickupDateController.text.isEmpty
                  ? ''
                  : _pickupDateController.text,
          'orders_gold_price_per_gram': _goldPricePerGramController.text,
          'orders_final_price': _finalPriceController.text,
          'orders_dp': _dpController.text,
          'orders_note': _notesController.text,
          'orders_created_at': createdAt,
          'orders_updated_at': createdAt,
          'orders_imagePaths': jsonEncode(_uploadedImageUrls),
          'orders_workflowStatus': 'waitingSalesCheck',
        },
      );
      setState(() => _isLoading = false);
      if (response.statusCode == 200) {
        final resp = jsonDecode(response.body);
        if (resp['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesanan berhasil ditambahkan!')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menambah pesanan: ${resp['error'] ?? 'Unknown error'}',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah pesanan: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambah pesanan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pesanan'),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
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
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: _luxuryDecoration(
                  'Alamat',
                  required: true,
                  icon: Icons.location_on,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
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
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedJewelryType = val),
                validator:
                    (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
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
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedGoldType = val),
                validator:
                    (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
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
                            child: Text(color),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedGoldColor = val),
                validator:
                    (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              if (_selectedJewelryType != null &&
                  (_selectedJewelryType!.toLowerCase().contains('ring'))) ...[
                TextFormField(
                  controller: _ringSizeController,
                  decoration: _luxuryDecoration('Ukuran Cincin'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Batu/Berlian',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  TextButton.icon(
                    onPressed:
                        () => setState(() => _stoneInputs.add(StoneInput())),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Batu'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_stoneInputs.isNotEmpty)
                Column(
                  children: [
                    ..._stoneInputs.asMap().entries.map((entry) {
                      final i = entry.key;
                      final input = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: input.shape,
                                  isDense: true,
                                  decoration: _luxuryDecoration('Bentuk Batu'),
                                  items:
                                      _stoneShapes
                                          .map(
                                            (shape) => DropdownMenuItem(
                                              value: shape,
                                              child: Text(shape),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) =>
                                          setState(() => input.shape = val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: input.countController,
                                  decoration: _luxuryDecoration('Jumlah'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Text('pcs'),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: input.caratController,
                                  decoration: _luxuryDecoration('Ukuran'),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Text('ct'),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => setState(() {
                                      input.dispose();
                                      _stoneInputs.removeAt(i);
                                    }),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              const SizedBox(height: 24),
              const Text(
                'Informasi Harga & Tanggal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              TextFormField(
                controller: _goldPricePerGramController,
                decoration: _luxuryDecoration('Harga Emas per Gram'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _finalPriceController,
                decoration: _luxuryDecoration('Harga Perkiraan'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dpController,
                decoration: _luxuryDecoration('DP'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _readyDateController,
                readOnly: true,
                onTap:
                    () => _pickDate(
                      _readyDateController,
                      _selectedReadyDate,
                      (d) => setState(() => _selectedReadyDate = d),
                    ),
                decoration: _luxuryDecoration(
                  'Tanggal Jadi',
                  icon: Icons.event,
                ).copyWith(
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pickupDateController,
                readOnly: true,
                onTap:
                    () => _pickDate(
                      _pickupDateController,
                      _selectedPickupDate,
                      (d) => setState(() => _selectedPickupDate = d),
                    ),
                decoration: _luxuryDecoration(
                  'Tanggal Ambil',
                  icon: Icons.event_available,
                ).copyWith(
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Referensi Gambar (Wajib)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._pickedImages.asMap().entries.map((entry) {
                      final i = entry.key;
                      final img = entry.value;
                      return Stack(
                        children: [
                          Container(
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
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(i),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
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
                    }),
                    GestureDetector(
                      onTap: _pickImages,
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
              const Text(
                'Catatan (Memo)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Tulis permintaan khusus atau catatan di sini...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
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
                    label: const Text('Simpan Pesanan'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
