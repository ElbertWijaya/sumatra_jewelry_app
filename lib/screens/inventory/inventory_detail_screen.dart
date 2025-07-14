import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../models/order.dart';
import '../../models/inventory.dart';
import '../../services/order_service.dart';
import '../../utils/thousand_separator_input_formatter.dart';

class InventoryDetailScreen extends StatefulWidget {
  final Order? order;
  final InventoryItem? inventoryItem;
  final bool isEdit;
  const InventoryDetailScreen({
    super.key,
    this.order,
    this.inventoryItem,
    this.isEdit = false,
  });

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  Order? _order;
  InventoryItem? _inventoryItem;
  // Inventory form fields
  final _formKey = GlobalKey<FormState>();
  String? inventoryProductId;
  String? originalInventoryProductId;
  String? inventoryJewelryType;
  String? inventoryGoldColor;
  String? inventoryGoldType;
  List<Map<String, dynamic>> inventoryStoneUsed = [];
  List<File> inventoryImageFiles = [];
  List<String> inventoryImageUrls = [];
  double? inventoryItemsPrice;
  String? inventoryRingSize;

  // Dropdown options
  final List<String> jewelryTypes = [
    'Bangle',
    'Ring',
    'Earrings',
    'Necklace',
    'Bracelet',
    'Pendant',
    'Men Ring',
    'Women Ring',
  ];
  final List<String> goldColors = ['White Gold', 'Rose Gold', 'Yellow Gold'];
  final List<String> goldTypes = ['24K', '22K', '18K', '14K', '10K', '9K'];
  final List<String> stoneShapes = [
    'Round',
    'Heart',
    'Princess',
    'Marquise',
    'Oval',
    'Pear',
    'Cushion',
    'Emerald',
    'Asscher',
    'Radiant',
  ];

  bool _isProcessing = false;
  bool _isLoading = true;
  bool _inventorySaved = false;
  bool _isUploadingImages = false;

  @override
  void initState() {
    super.initState();
    if (widget.inventoryItem != null) {
      _inventoryItem = widget.inventoryItem;
      originalInventoryProductId = _inventoryItem?.id; // store original id
      _isLoading = false;
    } else if (widget.order != null) {
      _order = widget.order;
      _fetchOrderDetail();
    }
  }

  Future<void> _fetchOrderDetail() async {
    if (widget.order == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final refreshedOrder = await OrderService().getOrderById(
        widget.order!.id,
      );
      setState(() {
        _order = refreshedOrder;
        // Prefill jika sudah ada data inventory
        inventoryProductId = _order?.inventoryProductId;
        inventoryJewelryType = _order?.inventoryJewelryType;
        inventoryGoldColor = _order?.inventoryGoldColor;
        inventoryGoldType = _order?.inventoryGoldType;
        inventoryStoneUsed = List<Map<String, dynamic>>.from(
          _order?.inventoryStoneUsed ?? [],
        );
        inventoryImageFiles =
            (_order?.inventoryImagePaths ?? []).map((p) => File(p)).toList();
        inventoryItemsPrice = _order?.inventoryItemsPrice;
        inventoryRingSize = _order?.inventoryRingSize;
      });
    } catch (e) {
      setState(() {
        _order = widget.order;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        inventoryImageFiles = picked.map((x) => File(x.path)).toList();
      });
    }
  }

  Future<void> _pickInventoryImages() async {
    setState(() {
      _isUploadingImages = true;
    });
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      List<String> urls = [];
      for (final img in picked) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
            'http://192.168.83.117/sumatra_api/upload_inventory_image.php',
          ),
        );
        request.files.add(await http.MultipartFile.fromPath('image', img.path));
        var response = await request.send();
        if (response.statusCode == 200) {
          var respStr = await response.stream.bytesToString();
          var jsonResp = json.decode(respStr);
          if (jsonResp['success'] == true && jsonResp['url'] != null) {
            urls.add(jsonResp['url']);
          }
        }
      }
      setState(() {
        inventoryImageUrls = urls;
        _isUploadingImages = false;
      });
    } else {
      setState(() {
        _isUploadingImages = false;
      });
    }
  }

  bool get _isRingType =>
      inventoryJewelryType == 'Ring' ||
      inventoryJewelryType == 'Men Ring' ||
      inventoryJewelryType == 'Women Ring';

  bool get _canSubmit {
    // Semua field wajib harus terisi, KECUALI inventoryStoneUsed
    return inventoryProductId != null &&
        inventoryProductId!.isNotEmpty &&
        inventoryJewelryType != null &&
        inventoryJewelryType!.isNotEmpty &&
        inventoryGoldColor != null &&
        inventoryGoldColor!.isNotEmpty &&
        inventoryGoldType != null &&
        inventoryGoldType!.isNotEmpty &&
        inventoryImageUrls.isNotEmpty &&
        (inventoryItemsPrice ?? 0) > 0 &&
        (!_isRingType || ((inventoryRingSize?.isNotEmpty ?? false)));
  }

  Future<void> _submitToFinishing() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order!.copyWith(
        inventoryProductId: inventoryProductId,
        inventoryJewelryType: inventoryJewelryType,
        inventoryGoldColor: inventoryGoldColor,
        inventoryGoldType: inventoryGoldType,
        inventoryStoneUsed: inventoryStoneUsed,
        inventoryImagePaths: inventoryImageUrls,
        inventoryItemsPrice: inventoryItemsPrice,
        inventoryRingSize: _isRingType ? inventoryRingSize : null,
        workflowStatus: OrderWorkflowStatus.waitingFinishing,
      );
      await OrderService().updateOrder(updatedOrder);
      await _fetchOrderDetail();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order berhasil disubmit ke Sales')),
      );
      Navigator.of(context).pop(true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateInventory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order!.copyWith(
        inventoryProductId: inventoryProductId,
        inventoryJewelryType: inventoryJewelryType,
        inventoryGoldColor: inventoryGoldColor,
        inventoryGoldType: inventoryGoldType,
        inventoryStoneUsed: inventoryStoneUsed,
        inventoryImagePaths: inventoryImageUrls,
        inventoryItemsPrice: inventoryItemsPrice,
        inventoryRingSize: _isRingType ? inventoryRingSize : null,
        workflowStatus:
            OrderWorkflowStatus
                .waitingSalesCompletion, // langsung update status
      );
      await OrderService().updateOrder(updatedOrder);
      // INSERT: SELALU kirim inventory_id agar backend treat as insert
      final body = {
        'inventory_id': _order!.id, // <-- WAJIB ADA!
        'inventory_product_id': inventoryProductId ?? '',
        'inventory_jewelry_type': inventoryJewelryType ?? '',
        'inventory_gold_color': inventoryGoldColor ?? '',
        'inventory_gold_type': inventoryGoldType ?? '',
        'inventory_ring_size': inventoryRingSize ?? '',
        'inventory_items_price': inventoryItemsPrice?.toString() ?? '',
        'inventory_stone_used': jsonEncode(inventoryStoneUsed),
        'inventory_imagePaths': jsonEncode(inventoryImageUrls),
      };
      print('[DEBUG] Insert Inventory Body: $body');
      final response = await http.post(
        Uri.parse('http://192.168.83.117/sumatra_api/update_inventory.php'),
        body: body,
      );
      print('[DEBUG] Insert Inventory Response: ${response.body}');
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        setState(() {
          _inventorySaved = true;
        });
        await _fetchOrderDetail();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data inventory berhasil dibuat!')),
        );
        Navigator.of(context).pop(true);
      } else {
        print(
          '[DEBUG] Backend error: ${result['error']?.toString() ?? 'Unknown error'}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat inventory: \\${result['error']}'),
          ),
        );
      }
      await _fetchOrderDetail();
    } catch (e) {
      print('[DEBUG] Error saat insert inventory: $e');
      setState(() {
        _order = widget.order;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveInventoryEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    try {
      // UPDATE: WAJIB kirim inventory_id agar backend treat as update
      final body = {
        'inventory_id': _inventoryItem?.inventoryId?.toString() ?? '',
        'inventory_product_id': inventoryProductId ?? '',
        'inventory_jewelry_type': inventoryJewelryType ?? '',
        'inventory_gold_color': inventoryGoldColor ?? '',
        'inventory_gold_type': inventoryGoldType ?? '',
        'inventory_ring_size': inventoryRingSize ?? '',
        'inventory_items_price': inventoryItemsPrice?.toString() ?? '',
        'inventory_stone_used': jsonEncode(inventoryStoneUsed),
        'inventory_imagePaths': jsonEncode(inventoryImageUrls),
      };
      print('[DEBUG] Update Inventory Body: $body');
      final response = await http.post(
        Uri.parse('http://192.168.83.117/sumatra_api/update_inventory.php'),
        body: body,
      );
      print('[DEBUG] Update Inventory Response: ${response.body}');
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perubahan inventory berhasil disimpan!'),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        print(
          '[DEBUG] Backend error: ${result['error']?.toString() ?? 'Unknown error'}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal update inventory: \\${result['error'] ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e) {
      print('[DEBUG] Error saat update inventory: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error: \\${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildStoneList() {
    print('inventoryStoneUsed: $inventoryStoneUsed');
    print('stoneShapes: $stoneShapes');
    return Column(
      children: [
        ...inventoryStoneUsed.asMap().entries.map((entry) {
          final idx = entry.key;
          final stone = entry.value;
          print('stone[$idx]: $stone');
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: stone['shape'],
                      items:
                          stoneShapes
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          inventoryStoneUsed[idx]['shape'] = val;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Bentuk Batu',
                      ),
                      validator:
                          (val) =>
                              inventoryStoneUsed.isEmpty
                                  ? null
                                  : (val == null || val.isEmpty
                                      ? 'Pilih bentuk'
                                      : null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: stone['count']?.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Jumlah'),
                      onChanged: (val) {
                        setState(() {
                          inventoryStoneUsed[idx]['count'] =
                              int.tryParse(val) ?? 0;
                        });
                      },
                      validator:
                          (val) =>
                              inventoryStoneUsed.isEmpty
                                  ? null
                                  : ((val == null || val.isEmpty)
                                      ? 'Isi'
                                      : (int.tryParse(val) == null ||
                                          int.tryParse(val)! <= 0)
                                      ? 'Harus > 0'
                                      : null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      initialValue: stone['carat']?.toString(),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Carat',
                        suffixText: 'ct',
                      ),
                      onChanged: (val) {
                        setState(() {
                          inventoryStoneUsed[idx]['carat'] =
                              double.tryParse(val) ?? 0.0;
                        });
                      },
                      validator:
                          (val) =>
                              inventoryStoneUsed.isEmpty
                                  ? null
                                  : ((val == null || val.isEmpty)
                                      ? 'Isi'
                                      : (double.tryParse(val) == null ||
                                          double.tryParse(val)! <= 0)
                                      ? 'Harus > 0'
                                      : null),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        inventoryStoneUsed.removeAt(idx);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Tambah Batu'),
            onPressed: () {
              setState(() {
                inventoryStoneUsed.add({
                  'shape': null,
                  'count': null,
                  'carat': null,
                });
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWorking = _order?.workflowStatus == OrderWorkflowStatus.inventory;
    final isInventoryView =
        _order?.workflowStatus == OrderWorkflowStatus.waitingSalesCompletion;

    // LOGS for dropdowns
    print('inventoryJewelryType: $inventoryJewelryType');
    print('jewelryTypes: $jewelryTypes');
    print('inventoryGoldColor: $inventoryGoldColor');
    print('inventoryGoldType: $inventoryGoldType');
    print('inventoryRingSize: $inventoryRingSize');
    print('inventoryProductId: $inventoryProductId');
    print('inventoryImageFiles: $inventoryImageFiles');
    print('inventoryItemsPrice: $inventoryItemsPrice');

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_inventoryItem != null) {
      final item = _inventoryItem!;
      if (widget.isEdit) {
        // Prefill field jika belum diisi
        inventoryProductId ??= item.id;
        inventoryJewelryType ??= item.jewelryType;
        inventoryGoldType ??= item.goldType;
        inventoryGoldColor ??= item.goldColor;
        inventoryRingSize ??= item.ringSize;
        inventoryItemsPrice ??= item.itemsPrice;
        inventoryImageUrls =
            inventoryImageUrls.isNotEmpty
                ? inventoryImageUrls
                : List<String>.from(item.imagePaths);
        inventoryStoneUsed =
            inventoryStoneUsed.isNotEmpty
                ? inventoryStoneUsed
                : List<Map<String, dynamic>>.from(item.stoneUsed ?? []);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Inventory'),
            backgroundColor: const Color(0xFFD4AF37),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: inventoryProductId,
                    decoration: const InputDecoration(
                      labelText: 'Inventory Product ID *',
                    ),
                    onChanged:
                        (val) => setState(() => inventoryProductId = val),
                    validator:
                        (val) =>
                            (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value:
                        jewelryTypes.contains(inventoryJewelryType)
                            ? inventoryJewelryType
                            : null,
                    items:
                        jewelryTypes
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Jenis Perhiasan *',
                    ),
                    onChanged: (val) {
                      setState(() {
                        inventoryJewelryType = val;
                        if (!_isRingType) inventoryRingSize = null;
                      });
                    },
                    validator:
                        (val) =>
                            (val == null || val.isEmpty)
                                ? 'Wajib dipilih'
                                : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value:
                        goldColors.contains(inventoryGoldColor)
                            ? inventoryGoldColor
                            : null,
                    items:
                        goldColors
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Warna Emas *',
                    ),
                    onChanged:
                        (val) => setState(() => inventoryGoldColor = val),
                    validator:
                        (val) =>
                            (val == null || val.isEmpty)
                                ? 'Wajib dipilih'
                                : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value:
                        goldTypes.contains(inventoryGoldType)
                            ? inventoryGoldType
                            : null,
                    items:
                        goldTypes
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Jenis Emas *',
                    ),
                    onChanged: (val) => setState(() => inventoryGoldType = val),
                    validator:
                        (val) =>
                            (val == null || val.isEmpty)
                                ? 'Wajib dipilih'
                                : null,
                  ),
                  const SizedBox(height: 8),
                  _buildStoneList(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickInventoryImages,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Upload Foto Inventory'),
                      ),
                    ],
                  ),
                  if (inventoryImageUrls.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            inventoryImageUrls.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final img = entry.value;
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.network(
                                      img,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Image.asset(
                                          'assets/images/no_image.png',
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          inventoryImageUrls.removeAt(idx);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                            }).toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: inventoryItemsPrice?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Barang Akhir *',
                      prefixText: 'Rp ',
                    ),
                    inputFormatters: [ThousandSeparatorInputFormatter()],
                    onChanged: (val) {
                      final cleanVal =
                          val.replaceAll('.', '').replaceAll('Rp ', '').trim();
                      inventoryItemsPrice = double.tryParse(cleanVal);
                    },
                    validator:
                        (val) =>
                            (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  if (_isRingType)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextFormField(
                        initialValue: inventoryRingSize,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Cincin *',
                        ),
                        onChanged: (val) => inventoryRingSize = val,
                        validator:
                            (val) =>
                                (val == null || val.isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        _isProcessing || !_canSubmit
                            ? null
                            : _saveInventoryEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child:
                        _isProcessing
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Simpan Perubahan'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      // Pilihan 2: Timeline/Stepper style
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Inventory'),
          backgroundColor: const Color(0xFFD4AF37),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gambar utama
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child:
                      item.imagePaths.isNotEmpty
                          ? Image.network(
                            item.imagePaths.first,
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 180,
                                  height: 180,
                                  color: Colors.brown[100],
                                  child: const Icon(
                                    Icons.image,
                                    size: 60,
                                    color: Colors.brown,
                                  ),
                                ),
                          )
                          : Container(
                            width: 180,
                            height: 180,
                            color: Colors.brown[100],
                            child: const Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.brown,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 18),
              // Info utama (ID)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.confirmation_number,
                    color: Color(0xFFD4AF37),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ID: ${item.id}',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Timeline/Stepper info detail
              Column(
                children: [
                  _buildTimelineTile(
                    Icons.category,
                    'Jenis Perhiasan',
                    item.jewelryType,
                  ),
                  _buildTimelineTile(
                    Icons.color_lens,
                    'Warna Emas',
                    item.goldColor,
                  ),
                  _buildTimelineTile(Icons.grade, 'Jenis Emas', item.goldType),
                  // Kotak info batu
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color(0xFFD4AF37),
                          width: 1.2,
                        ),
                      ),
                      child:
                          (item.stoneUsed != null && item.stoneUsed!.isNotEmpty)
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    item.stoneUsed!.map((stone) {
                                      final shape = stone['shape'] ?? '-';
                                      final count = stone['count'] ?? '-';
                                      final carat =
                                          stone['carat'] != null
                                              ? stone['carat'].toString()
                                              : '-';
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          '$shape : $count/$carat ct',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF7C5E2C),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ),
                  _buildTimelineTile(
                    Icons.price_check,
                    'Harga Barang',
                    _formatRupiah(item.itemsPrice),
                  ),
                  if (item.ringSize != null && item.ringSize!.isNotEmpty)
                    _buildTimelineTile(
                      Icons.circle_outlined,
                      'Ukuran Cincin',
                      item.ringSize ?? '-',
                    ),
                  _buildTimelineTile(
                    Icons.calendar_today,
                    'Tanggal Input',
                    item.createdAt ?? '-',
                  ),
                  _buildTimelineTile(
                    Icons.update,
                    'Tanggal Update',
                    item.updatedAt ?? '-',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Foto lain
              if (item.imagePaths.length > 1) ...[
                const Text(
                  'Foto Lainnya:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        item.imagePaths
                            .skip(1)
                            .map(
                              (img) => Container(
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xFFD4AF37),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    img,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.brown[100],
                                              child: const Icon(
                                                Icons.image,
                                                size: 30,
                                                color: Colors.brown,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    // Detail order
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child:
                    isInventoryView
                        ? ListView(
                          children: [
                            const Text(
                              'Data Inventory',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF7C5E2C),
                              ),
                            ),
                            const Divider(),
                            Text(
                              'Product ID: ${_order!.inventoryProductId ?? "-"}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Jenis Perhiasan: ${_order!.inventoryJewelryType ?? "-"}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Jenis Emas: ${_order!.inventoryGoldType ?? "-"}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Warna Emas: ${_order!.inventoryGoldColor ?? "-"}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Ukuran Cincin: ${_order!.inventoryRingSize ?? "-"}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Harga Barang Akhir: Rp ${_order!.inventoryItemsPrice?.toStringAsFixed(0) ?? "-"}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Tanggal Input Inventory: ${_order!.updatedAt != null ? '${_order!.updatedAt!.day}/${_order!.updatedAt!.month}/${_order!.updatedAt!.year}' : '-'}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Foto Inventory',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF7C5E2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 90,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  ...?_order!.inventoryImagePaths?.map(
                                    (img) => Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.amber),
                                        image: DecorationImage(
                                          image:
                                              img.startsWith('http')
                                                  ? NetworkImage(img)
                                                  : AssetImage(
                                                        'assets/images/no_image.png',
                                                      )
                                                      as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Batu yang Digunakan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF7C5E2C),
                              ),
                            ),
                            if ((_order!.inventoryStoneUsed ?? []).isEmpty)
                              const Text('Tidak ada data batu.'),
                            ...?_order!.inventoryStoneUsed?.map(
                              (stone) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  'Bentuk: ${stone['shape'] ?? "-"}, Jumlah: ${stone['count'] ?? "-"}, Carat: ${stone['carat'] ?? "-"}',
                                  style: const TextStyle(
                                    color: Color(0xFF7C5E2C),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : ListView(
                          children: [
                            // Informasi Pelanggan
                            const Text(
                              'Informasi Pelanggan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF7C5E2C),
                              ),
                            ),
                            const Divider(),
                            Text(
                              'Nama: ${_order!.customerName}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Kontak: ${_order!.customerContact}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Alamat: ${_order!.address}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            const SizedBox(height: 12),

                            // Informasi Barang
                            const Text(
                              'Informasi Barang',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF7C5E2C),
                              ),
                            ),
                            const Divider(),
                            Text(
                              'Jenis Perhiasan: ${_order!.jewelryType}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Jenis Emas: ${_order!.goldType}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Warna Emas: ${_order!.goldColor}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Ukuran Cincin: ${_order!.ringSize}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Tipe Batu: ${_order!.stoneType}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Ukuran Batu: ${_order!.stoneSize}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            const SizedBox(height: 12),

                            // Informasi Harga
                            const Text(
                              'Informasi Harga',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF7C5E2C),
                              ),
                            ),
                            const Divider(),
                            Text(
                              'Harga Perkiraan: Rp ${_order!.finalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Harga Emas per Gram: Rp ${_order!.goldPricePerGram.toStringAsFixed(0)}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'DP: Rp ${_order!.dp.toStringAsFixed(0)}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Sisa Lunas: Rp ${(_order!.finalPrice - _order!.dp).clamp(0, double.infinity).toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(height: 12),

                            // Informasi Tanggal
                            const Text(
                              'Informasi Tanggal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF7C5E2C),
                              ),
                            ),
                            const Divider(),
                            Text(
                              'Tanggal Order: ${_order!.createdAt.day}/${_order!.createdAt.month}/${_order!.createdAt.year}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Tanggal Ambil: ${_order!.pickupDate != null ? "${_order!.pickupDate!.day}/${_order!.pickupDate!.month}/${_order!.pickupDate!.year}" : "-"}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            Text(
                              'Tanggal Jadi: ${_order!.readyDate != null ? "${_order!.readyDate!.day}/${_order!.readyDate!.month}/${_order!.readyDate!.year}" : "-"}',
                              style: const TextStyle(color: Color(0xFF7C5E2C)),
                            ),
                            const SizedBox(height: 12),

                            // Gambar Referensi
                            const Text(
                              'Referensi Gambar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF7C5E2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 90,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  ..._order!.imagePaths.map(
                                    (img) => Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.amber),
                                        image: DecorationImage(
                                          image:
                                              img.startsWith('http')
                                                  ? NetworkImage(img)
                                                  : AssetImage(
                                                        'assets/images/no_image.png',
                                                      )
                                                      as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Catatan
                            const Text(
                              'Catatan (Memo)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF7C5E2C),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.amber[200]!),
                              ),
                              child: Text(
                                _order!.notes,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            // Status
                            if (!isInventoryView) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Status: ${_order!.workflowStatus.label}',
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],

                            // Tombol Terima Pesanan
                            if (_order!.workflowStatus ==
                                OrderWorkflowStatus.waitingInventory) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Terima Pesanan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                onPressed:
                                    _isProcessing
                                        ? null
                                        : () async {
                                          setState(() => _isProcessing = true);
                                          try {
                                            final updatedOrder = _order!
                                                .copyWith(
                                                  workflowStatus:
                                                      OrderWorkflowStatus
                                                          .inventory,
                                                );
                                            await OrderService().updateOrder(
                                              updatedOrder,
                                            );
                                            await _fetchOrderDetail();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Pesanan diterima, status menjadi Inventory',
                                                ),
                                              ),
                                            );
                                            Navigator.of(context).pop(true);
                                          } finally {
                                            setState(
                                              () => _isProcessing = false,
                                            );
                                          }
                                        },
                              ),
                            ],

                            const SizedBox(height: 16),
                            const Divider(),
                            const Text(
                              'Input Data Inventory',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (isWorking)
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      initialValue: inventoryProductId,
                                      decoration: const InputDecoration(
                                        labelText: 'Inventory Product ID *',
                                      ),
                                      onChanged:
                                          (val) => inventoryProductId = val,
                                      validator:
                                          (val) =>
                                              (val == null || val.isEmpty)
                                                  ? 'Wajib diisi'
                                                  : null,
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value:
                                          jewelryTypes.contains(
                                                inventoryJewelryType,
                                              )
                                              ? inventoryJewelryType
                                              : null,
                                      items:
                                          jewelryTypes
                                              .map(
                                                (t) => DropdownMenuItem(
                                                  value: t,
                                                  child: Text(t),
                                                ),
                                              )
                                              .toList(),
                                      decoration: const InputDecoration(
                                        labelText: 'Jenis Perhiasan *',
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          inventoryJewelryType = val;
                                          if (!_isRingType)
                                            inventoryRingSize = null;
                                        });
                                      },
                                      validator:
                                          (val) =>
                                              (val == null || val.isEmpty)
                                                  ? 'Wajib dipilih'
                                                  : null,
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value:
                                          goldColors.contains(
                                                inventoryGoldColor,
                                              )
                                              ? inventoryGoldColor
                                              : null,
                                      items:
                                          goldColors
                                              .map(
                                                (t) => DropdownMenuItem(
                                                  value: t,
                                                  child: Text(t),
                                                ),
                                              )
                                              .toList(),
                                      decoration: const InputDecoration(
                                        labelText: 'Warna Emas *',
                                      ),
                                      onChanged:
                                          (val) => setState(
                                            () => inventoryGoldColor = val,
                                          ),
                                      validator:
                                          (val) =>
                                              (val == null || val.isEmpty)
                                                  ? 'Wajib dipilih'
                                                  : null,
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value:
                                          goldTypes.contains(inventoryGoldType)
                                              ? inventoryGoldType
                                              : null,
                                      items:
                                          goldTypes
                                              .map(
                                                (t) => DropdownMenuItem(
                                                  value: t,
                                                  child: Text(t),
                                                ),
                                              )
                                              .toList(),
                                      decoration: const InputDecoration(
                                        labelText: 'Jenis Emas *',
                                      ),
                                      onChanged:
                                          (val) => setState(
                                            () => inventoryGoldType = val,
                                          ),
                                      validator:
                                          (val) =>
                                              (val == null || val.isEmpty)
                                                  ? 'Wajib dipilih'
                                                  : null,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStoneList(),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: _pickInventoryImages,
                                          icon: const Icon(Icons.add_a_photo),
                                          label: const Text(
                                            'Upload Foto Inventory',
                                          ),
                                        ),
                                      ],
                                    ),
                                    if ((inventoryImageUrls).isNotEmpty)
                                      SizedBox(
                                        height: 80,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children:
                                              inventoryImageUrls.asMap().entries.map((
                                                entry,
                                              ) {
                                                final idx = entry.key;
                                                final img = entry.value;
                                                return Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      child: Image.network(
                                                        img,
                                                        width: 70,
                                                        height: 70,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Image.asset(
                                                            'assets/images/no_image.png',
                                                            width: 70,
                                                            height: 70,
                                                            fit: BoxFit.cover,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            inventoryImageUrls
                                                                .removeAt(idx);
                                                          });
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors.black54,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
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
                                              }).toList(),
                                        ),
                                      ),
                                    // Tambahkan input harga barang akhir
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      initialValue:
                                          inventoryItemsPrice?.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Harga Barang Akhir *',
                                        prefixText: 'Rp ',
                                      ),
                                      inputFormatters: [
                                        ThousandSeparatorInputFormatter(),
                                      ],
                                      onChanged: (val) {
                                        final cleanVal =
                                            val
                                                .replaceAll('.', '')
                                                .replaceAll('Rp ', '')
                                                .trim();
                                        inventoryItemsPrice = double.tryParse(
                                          cleanVal,
                                        );
                                      },
                                      validator:
                                          (val) =>
                                              (val == null || val.isEmpty)
                                                  ? 'Wajib diisi'
                                                  : null,
                                    ),
                                    if (_isRingType)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: TextFormField(
                                          initialValue: inventoryRingSize,
                                          decoration: const InputDecoration(
                                            labelText: 'Ukuran Cincin *',
                                          ),
                                          onChanged:
                                              (val) => inventoryRingSize = val,
                                          validator:
                                              (val) =>
                                                  (val == null || val.isEmpty)
                                                      ? 'Wajib diisi'
                                                      : null,
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.save),
                                      label: const Text('Buat Database'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(48),
                                      ),
                                      onPressed:
                                          _isProcessing ||
                                                  !_canSubmit ||
                                                  _isUploadingImages
                                              ? null
                                              : _updateInventory,
                                    ),
                                    if (_isUploadingImages)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          children: [
                                            CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                            SizedBox(width: 10),
                                            Text('Mengupload gambar...'),
                                          ],
                                        ),
                                      ),
                                    if (!_canSubmit && !_isUploadingImages)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          _isRingType &&
                                                  (inventoryRingSize == null ||
                                                      inventoryRingSize!
                                                          .isEmpty)
                                              ? 'Ukuran cincin wajib diisi.'
                                              : (inventoryProductId == null ||
                                                  inventoryProductId!.isEmpty)
                                              ? 'Product ID wajib diisi.'
                                              : (inventoryJewelryType == null ||
                                                  inventoryJewelryType!.isEmpty)
                                              ? 'Jenis perhiasan wajib dipilih.'
                                              : (inventoryGoldColor == null ||
                                                  inventoryGoldColor!.isEmpty)
                                              ? 'Warna emas wajib dipilih.'
                                              : (inventoryGoldType == null ||
                                                  inventoryGoldType!.isEmpty)
                                              ? 'Jenis emas wajib dipilih.'
                                              : (inventoryImageUrls.isEmpty)
                                              ? 'Minimal 1 foto inventory harus diupload.'
                                              : (inventoryItemsPrice == null ||
                                                  inventoryItemsPrice! <= 0)
                                              ? 'Harga barang akhir wajib diisi.'
                                              : '',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
              ),
    );
  }

  Widget _buildTimelineTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7C5E2C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tambahkan fungsi format rupiah
  String _formatRupiah(num? value) {
    if (value == null) return '-';
    final str = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    final formatted = buffer.toString().split('').reversed.join();
    return 'Rp $formatted';
  }
}
