import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../models/order.dart';
import '../../services/order_service.dart';

class InventoryInputFormScreen extends StatefulWidget {
  final Order? order;
  const InventoryInputFormScreen({super.key, this.order});

  @override
  State<InventoryInputFormScreen> createState() =>
      _InventoryInputFormScreenState();
}

class _InventoryInputFormScreenState extends State<InventoryInputFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _ringSizeController = TextEditingController();
  final TextEditingController _itemsPriceController = TextEditingController();

  // Dropdown values
  String? _selectedJewelryType;
  String? _selectedGoldType;
  String? _selectedGoldColor;

  // Images
  final List<XFile> _images = [];

  // Stone used
  final List<_StoneInput> _stones = [];

  // Jewelry type options
  static const List<String> jewelryTypes = [
    'Ring',
    'Bangle',
    'Earring',
    'Pendant',
    'Hairpin',
    'Pin',
    'Men Ring',
    'Women Ring',
    'Wedding Ring',
  ];

  // Gold type options
  static const List<String> goldTypes = ['19K', '18K', '14K', '9K'];

  // Gold color options
  static const List<String> goldColors = [
    'White Gold',
    'Rose Gold',
    'Yellow Gold',
  ];

  // Stone shape options
  static const List<String> stoneShapes = [
    'Round',
    'Princess',
    'Oval',
    'Cushion',
    'Pear',
    'Marquise',
    'Heart',
    'Triangle',
    'Emerald',
    'Baguatte',
    'Octagon',
  ];

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  String _rawPrice = '';

  @override
  void initState() {
    super.initState();
    _productIdController.text = '';
    _ringSizeController.text = '';
    _itemsPriceController.text = '';
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _ringSizeController.dispose();
    _itemsPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _addStone() {
    setState(() {
      _stones.add(_StoneInput());
    });
  }

  void _removeStone(int index) {
    setState(() {
      _stones.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> urls = [];
    for (final image in images) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.7.25/sumatra_api/upload_inventory_image.php'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final jsonResp = jsonDecode(respStr);
        if (jsonResp['success'] == true && jsonResp['url'] != null) {
          urls.add(jsonResp['url']);
        }
      }
    }
    return urls;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal 1 gambar harus diupload!')),
      );
      return;
    }

    // Upload images ke server dan dapatkan URL
    List<String> imageUrls = await _uploadImages(_images);
    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal upload gambar!')));
      return;
    }

    // Kumpulkan data
    final Map<String, dynamic> inventoryData = {
      'inventory_id': widget.order?.ordersId,
      'inventory_product_id': _productIdController.text,
      'inventory_jewelry_type': _selectedJewelryType,
      'inventory_gold_type': _selectedGoldType,
      'inventory_gold_color': _selectedGoldColor,
      'inventory_ring_size':
          (_selectedJewelryType == 'Men Ring' ||
                  _selectedJewelryType == 'Women Ring' ||
                  _selectedJewelryType == 'Wedding Ring')
              ? _ringSizeController.text
              : '',
      'inventory_items_price': _rawPrice,
      'inventory_imagePaths': jsonEncode(imageUrls),
      'inventory_stone_used': jsonEncode(
        _stones
            .where((s) => s.isFilled)
            .map(
              (s) => {
                'shape': s.shape,
                'count': s.countController.text,
                'weight': s.weightController.text,
              },
            )
            .toList(),
      ),
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.7.25/sumatra_api/update_inventory.php'),
        body: inventoryData,
      );
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        // Update workflow_status order ke waitingSalesCompletion
        final updatedOrder = widget.order!.copyWith(
          ordersWorkflowStatus: OrderWorkflowStatus.waitingSalesCompletion,
        );
        await OrderService().updateOrder(updatedOrder);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data inventory berhasil disimpan!')),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/inventory/dashboard',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan data: \\${result['error'] ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error: \\${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data Inventory'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kode Barang
                TextFormField(
                  controller: _productIdController,
                  decoration: const InputDecoration(labelText: 'Kode Barang *'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Jenis Perhiasan
                DropdownButtonFormField<String>(
                  value: _selectedJewelryType,
                  items:
                      jewelryTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedJewelryType = val;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Jenis Perhiasan *',
                  ),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Jenis Emas
                DropdownButtonFormField<String>(
                  value: _selectedGoldType,
                  items:
                      goldTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedGoldType = val),
                  decoration: const InputDecoration(labelText: 'Jenis Emas *'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Warna Emas
                DropdownButtonFormField<String>(
                  value: _selectedGoldColor,
                  items:
                      goldColors
                          .map(
                            (color) => DropdownMenuItem(
                              value: color,
                              child: Text(color),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedGoldColor = val),
                  decoration: const InputDecoration(labelText: 'Warna Emas *'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Ring Size (hanya jika tipe perhiasan tertentu)
                if (_selectedJewelryType == 'Men Ring' ||
                    _selectedJewelryType == 'Women Ring' ||
                    _selectedJewelryType == 'Wedding Ring')
                  Column(
                    children: [
                      TextFormField(
                        controller: _ringSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Ring Size',
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Harga Barang
                TextFormField(
                  controller: _itemsPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Harga Barang *',
                  ),
                  keyboardType: TextInputType.number,
                  validator:
                      (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  onChanged: (value) {
                    // Hanya angka
                    String raw = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (raw.isEmpty) {
                      _itemsPriceController.text = '';
                      _rawPrice = '';
                      _itemsPriceController.selection = TextSelection.collapsed(
                        offset: 0,
                      );
                      return;
                    }
                    _rawPrice = raw;
                    String formatted = _currencyFormat.format(int.parse(raw));
                    _itemsPriceController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Upload Gambar
                Text(
                  'Upload Gambar * (minimal 1 gambar)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ..._images.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final img = entry.value;
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            // ignore: use_build_context_synchronously
                            File(img.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                          GestureDetector(
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
                        ],
                      );
                    }),
                    InkWell(
                      onTap: _pickImages,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Batu (opsional)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Batu yang Digunakan (opsional)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _addStone,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Batu'),
                    ),
                  ],
                ),
                ..._stones.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final stone = entry.value;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Bentuk
                          Flexible(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: stone.shape,
                              items:
                                  stoneShapes
                                      .map(
                                        (shape) => DropdownMenuItem(
                                          value: shape,
                                          child: Text(shape),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) => setState(() => stone.shape = val),
                              decoration: const InputDecoration(
                                labelText: 'Bentuk',
                              ),
                              validator: (v) {
                                if (_stones.contains(stone) &&
                                    (v == null || v.isEmpty)) {
                                  return 'Wajib';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Jumlah
                          Flexible(
                            flex: 2,
                            child: TextFormField(
                              controller: stone.countController,
                              decoration: const InputDecoration(
                                labelText: 'Jumlah',
                                suffixText: 'pcs',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Berat
                          Flexible(
                            flex: 2,
                            child: TextFormField(
                              controller: stone.weightController,
                              decoration: const InputDecoration(
                                labelText: 'Berat',
                                suffixText: 'ct',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeStone(idx),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Simpan Data'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class untuk input batu
class _StoneInput {
  String? shape;
  final TextEditingController countController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  bool get isFilled =>
      (shape != null && shape!.isNotEmpty) &&
      (countController.text.isNotEmpty || weightController.text.isNotEmpty);

  void dispose() {
    countController.dispose();
    weightController.dispose();
  }
}
