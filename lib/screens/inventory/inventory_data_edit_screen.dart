import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/inventory.dart';
import '../../services/inventory_service.dart';

class InventoryDataEditScreen extends StatefulWidget {
  final Inventory inventory;

  const InventoryDataEditScreen({super.key, required this.inventory});

  @override
  State<InventoryDataEditScreen> createState() =>
      _InventoryDataEditScreenState();
}

class _InventoryDataEditScreenState extends State<InventoryDataEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final InventoryService _inventoryService = InventoryService();

  // Form controllers
  late TextEditingController _ringSizeController;
  late TextEditingController _itemsPriceController;

  // Dropdown values
  String? _selectedJewelryType;
  String? _selectedGoldType;
  String? _selectedGoldColor;

  List<Map<String, dynamic>> _stoneUsed = [];
  List<String> _imagePaths = [];
  final List<File> _newImages = [];
  bool _isLoading = false;

  // Dropdown options
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

  static const List<String> goldTypes = ['19K', '18K', '14K', '9K'];

  static const List<String> goldColors = [
    'White Gold',
    'Rose Gold',
    'Yellow Gold',
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
    _initializeData();
  }

  void _initializeData() {
    _selectedJewelryType = widget.inventory.InventoryJewelryType;
    _selectedGoldType = widget.inventory.InventoryGoldType;
    _selectedGoldColor = widget.inventory.InventoryGoldColor;

    _ringSizeController = TextEditingController(
      text: widget.inventory.InventoryRingSize ?? '',
    );
    _itemsPriceController = TextEditingController();

    // Format price untuk display
    if (widget.inventory.InventoryItemsPrice != null &&
        widget.inventory.InventoryItemsPrice!.isNotEmpty) {
      _rawPrice = widget.inventory.InventoryItemsPrice!.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      if (_rawPrice.isNotEmpty) {
        String formatted = _currencyFormat.format(int.parse(_rawPrice));
        _itemsPriceController.text = formatted;
      }
    }

    _stoneUsed = List<Map<String, dynamic>>.from(
      widget.inventory.InventoryStoneUsed,
    );
    _imagePaths = List<String>.from(widget.inventory.InventoryImagePaths);
  }

  @override
  void dispose() {
    _ringSizeController.dispose();
    _itemsPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.173.96.56/sumatra_api/upload_inventory_image.php'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final result = jsonDecode(responseData);

      if (result['success'] == true) {
        return result['url'];
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  void _addStone() {
    setState(() {
      _stoneUsed.add({'shape': '', 'count': '', 'carat': ''});
    });
  }

  void _removeStone(int index) {
    setState(() {
      _stoneUsed.removeAt(index);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _saveInventory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload new images first
      List<String> uploadedUrls = [];
      for (File image in _newImages) {
        final url = await _uploadImage(image);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      // Combine existing and new image paths
      final allImagePaths = [..._imagePaths, ...uploadedUrls];

      // Create updated inventory
      final updatedInventory = widget.inventory.copyWith(
        InventoryJewelryType: _selectedJewelryType,
        InventoryGoldType: _selectedGoldType,
        InventoryGoldColor: _selectedGoldColor,
        InventoryRingSize: _ringSizeController.text,
        InventoryItemsPrice: _rawPrice,
        InventoryStoneUsed: _stoneUsed,
        InventoryImagePaths: allImagePaths,
        InventoryUpdatedAt: DateTime.now(),
      );

      final success = await _inventoryService.updateInventoryAPI(
        updatedInventory,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data inventory berhasil diupdate!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop(updatedInventory);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengupdate data inventory!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data Inventory'),
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveInventory,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Text(
                'Informasi Dasar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedJewelryType,
                items:
                    jewelryTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedJewelryType = val;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Jenis Perhiasan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis perhiasan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Material Information
              Text(
                'Informasi Material',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedGoldType,
                items:
                    goldTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedGoldType = val;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Jenis Emas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
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
                onChanged: (val) {
                  setState(() {
                    _selectedGoldColor = val;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Warna Emas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // Ring Size (hanya tampil untuk jenis ring tertentu)
              if (_selectedJewelryType == 'Ring' ||
                  _selectedJewelryType == 'Men Ring' ||
                  _selectedJewelryType == 'Women Ring' ||
                  _selectedJewelryType == 'Wedding Ring')
                Column(
                  children: [
                    TextFormField(
                      controller: _ringSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Ukuran Ring',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              const SizedBox(height: 16),

              // Price Information
              Text(
                'Informasi Harga',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _itemsPriceController,
                decoration: const InputDecoration(
                  labelText: 'Harga Item',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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

              // Stone Information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Informasi Batu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addStone,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Batu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._stoneUsed.asMap().entries.map((entry) {
                final index = entry.key;
                final stone = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Batu ${index + 1}'),
                            IconButton(
                              onPressed: () => _removeStone(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                        TextFormField(
                          initialValue: stone['shape'],
                          decoration: const InputDecoration(
                            labelText: 'Bentuk',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _stoneUsed[index]['shape'] = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: stone['count'],
                                decoration: const InputDecoration(
                                  labelText: 'Jumlah',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _stoneUsed[index]['count'] = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: stone['carat'],
                                decoration: const InputDecoration(
                                  labelText: 'Karat',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _stoneUsed[index]['carat'] = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gambar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Tambah Gambar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Existing images
              if (_imagePaths.isNotEmpty) ...[
                Text(
                  'Gambar Saat Ini:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagePaths.length,
                    itemBuilder: (context, index) {
                      final imageUrl =
                          _imagePaths[index].startsWith('http')
                              ? _imagePaths[index]
                              : 'http://10.173.96.56/sumatra_api/inventory_photo/${_imagePaths[index]}';
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // New images
              if (_newImages.isNotEmpty) ...[
                Text(
                  'Gambar Baru:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _newImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                                image: DecorationImage(
                                  image: FileImage(_newImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeNewImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
