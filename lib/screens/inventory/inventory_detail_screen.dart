import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../utils/thousand_separator_input_formatter.dart';

class InventoryDetailScreen extends StatefulWidget {
  final Order order;
  const InventoryDetailScreen({super.key, required this.order});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  // Inisialisasi dengan order kosong agar tidak LateInitializationError
  Order _order = Order(
    id: '',
    customerName: '',
    customerContact: '',
    address: '',
    jewelryType: '',
    createdAt: DateTime.now(),
  );
  // Inventory form fields
  final _formKey = GlobalKey<FormState>();
  String? inventoryProductId;
  String? inventoryJewelryType;
  String? inventoryGoldColor;
  String? inventoryGoldType;
  List<Map<String, dynamic>> inventoryStoneUsed = [];
  List<File> inventoryImageFiles = [];
  double? inventoryItemsPrice;
  String? inventoryRingSize;

  // Dropdown options
  final List<String> jewelryTypes = [
    'Bangle', 'Ring', 'Earrings', 'Necklace', 'Bracelet', 'Pendant', 'Men Ring', 'Women Ring'
  ];
  final List<String> goldColors = [
    'White Gold', 'Rose Gold', 'Yellow Gold'
  ];
  final List<String> goldTypes = [
    '24K', '22K', '18K', '14K', '10K', '9K'
  ];
  final List<String> stoneShapes = [
    'Round', 'Heart', 'Princess', 'Marquise', 'Oval', 'Pear', 'Cushion', 'Emerald', 'Asscher', 'Radiant'
  ];

  bool _isProcessing = false;
  bool _isLoading = true;
  bool _inventorySaved = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final refreshedOrder = await OrderService().getOrderById(widget.order.id);
      setState(() {
        _order = refreshedOrder;
        // Prefill jika sudah ada data inventory
        inventoryProductId = _order.inventoryProductId;
        inventoryJewelryType = _order.inventoryJewelryType;
        inventoryGoldColor = _order.inventoryGoldColor;
        inventoryGoldType = _order.inventoryGoldType;
        inventoryStoneUsed = List<Map<String, dynamic>>.from(_order.inventoryStoneUsed ?? []);
        inventoryImageFiles = (_order.inventoryImagePaths ?? []).map((p) => File(p)).toList();
        inventoryItemsPrice = _order.inventoryItemsPrice;
        inventoryRingSize = _order.inventoryRingSize;
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
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        inventoryImageFiles = picked.map((x) => File(x.path)).toList();
      });
    }
  }

  bool get _isRingType =>
      inventoryJewelryType == 'Ring' ||
      inventoryJewelryType == 'Men Ring' ||
      inventoryJewelryType == 'Women Ring';

  bool get _canSubmit {
    // Semua field wajib harus terisi
    final stonesValid = inventoryStoneUsed.isNotEmpty &&
      inventoryStoneUsed.every((stone) =>
        stone['shape'] != null && (stone['shape'] as String).isNotEmpty &&
        stone['count'] != null && stone['count'] > 0 &&
        stone['carat'] != null && stone['carat'] > 0
      );
    return inventoryProductId != null && inventoryProductId!.isNotEmpty &&
        inventoryJewelryType != null && inventoryJewelryType!.isNotEmpty &&
        inventoryGoldColor != null && inventoryGoldColor!.isNotEmpty &&
        inventoryGoldType != null && inventoryGoldType!.isNotEmpty &&
        stonesValid &&
        inventoryImageFiles.isNotEmpty &&
        (inventoryItemsPrice ?? 0) > 0 &&
        (!_isRingType || ((inventoryRingSize?.isNotEmpty ?? false)));
  }

  Future<void> _submitToFinishing() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    try {
      // Simpan data ke backend (pastikan OrderService.updateOrder mengirim data inventory ke PHP)
      final updatedOrder = _order.copyWith(
        inventoryProductId: inventoryProductId,
        inventoryJewelryType: inventoryJewelryType,
        inventoryGoldColor: inventoryGoldColor,
        inventoryGoldType: inventoryGoldType,
        inventoryStoneUsed: inventoryStoneUsed,
        inventoryImagePaths: inventoryImageFiles.map((f) => f.path).toList(),
        inventoryItemsPrice: inventoryItemsPrice,
        inventoryRingSize: _isRingType ? inventoryRingSize : null,
        workflowStatus: OrderWorkflowStatus.waitingFinishing,
      );
      await OrderService().updateOrder(updatedOrder);
      await _fetchOrderDetail();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order berhasil disubmit ke Finishing')),
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
      final updatedOrder = _order.copyWith(
        inventoryProductId: inventoryProductId,
        inventoryJewelryType: inventoryJewelryType,
        inventoryGoldColor: inventoryGoldColor,
        inventoryGoldType: inventoryGoldType,
        inventoryStoneUsed: inventoryStoneUsed,
        inventoryImagePaths: inventoryImageFiles.map((f) => f.path).toList(),
        inventoryItemsPrice: inventoryItemsPrice,
        inventoryRingSize: _isRingType ? inventoryRingSize : null,
        workflowStatus: _order.workflowStatus,
      );

      // Update order (seperti biasa)
      await OrderService().updateOrder(updatedOrder);

      // Update ke tabel inventory (endpoint baru)
      final response = await http.post(
        Uri.parse('http://192.168.187.174/sumatra_api/update_inventory.php'),
        body: {
          'order_id': _order.id,
          'product_id': inventoryProductId ?? '',
          'jewelry_type': inventoryJewelryType ?? '',
          'gold_color': inventoryGoldColor ?? '',
          'gold_type': inventoryGoldType ?? '',
          'stone_used': jsonEncode(inventoryStoneUsed),
          'image_paths': jsonEncode(inventoryImageFiles.map((f) => f.path).toList()),
          'items_price': inventoryItemsPrice?.toString() ?? '',
          'ring_size': inventoryRingSize ?? '',
        },
      );
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data inventory berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update inventory: ${result['error']}')),
        );
      }

      await _fetchOrderDetail();
    } finally {
      setState(() => _isProcessing = false);
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
                      items: stoneShapes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        setState(() {
                          inventoryStoneUsed[idx]['shape'] = val;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Bentuk Batu'),
                      validator: (val) => val == null || val.isEmpty ? 'Pilih bentuk' : null,
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
                          inventoryStoneUsed[idx]['count'] = int.tryParse(val) ?? 0;
                        });
                      },
                      validator: (val) => (val == null || val.isEmpty)
                          ? 'Isi'
                          : (int.tryParse(val) == null || int.tryParse(val)! <= 0)
                              ? 'Harus > 0'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      initialValue: stone['carat']?.toString(),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Carat',
                        suffixText: 'ct',
                      ),
                      onChanged: (val) {
                        setState(() {
                          inventoryStoneUsed[idx]['carat'] = double.tryParse(val) ?? 0.0;
                        });
                      },
                      validator: (val) => (val == null || val.isEmpty)
                          ? 'Isi'
                          : (double.tryParse(val) == null || double.tryParse(val)! <= 0)
                              ? 'Harus > 0'
                              : null,
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
                inventoryStoneUsed.add({'shape': null, 'count': null, 'carat': null});
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWorking = _order.workflowStatus == OrderWorkflowStatus.inventory;

    // LOGS for dropdowns
    print('inventoryJewelryType: $inventoryJewelryType');
    print('jewelryTypes: $jewelryTypes');
    print('inventoryGoldColor: $inventoryGoldColor');
    print('inventoryGoldType: $inventoryGoldType');
    print('inventoryRingSize: $inventoryRingSize');
    print('inventoryProductId: $inventoryProductId');
    print('inventoryImageFiles: $inventoryImageFiles');
    print('inventoryItemsPrice: $inventoryItemsPrice');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // Informasi Pelanggan
                  const Text('Informasi Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                  const Divider(),
                  Text('Nama: ${_order.customerName}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Kontak: ${_order.customerContact}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Alamat: ${_order.address}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  const SizedBox(height: 12),

                  // Informasi Barang
                  const Text('Informasi Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                  const Divider(),
                  Text('Jenis Perhiasan: ${_order.jewelryType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Jenis Emas: ${_order.goldType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Warna Emas: ${_order.goldColor}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Ukuran Cincin: ${_order.ringSize}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Tipe Batu: ${_order.stoneType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Ukuran Batu: ${_order.stoneSize}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  const SizedBox(height: 12),

                  // Informasi Harga
                  const Text('Informasi Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                  const Divider(),
                  Text('Harga Perkiraan: Rp ${_order.finalPrice.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Harga Emas per Gram: Rp ${_order.goldPricePerGram.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('DP: Rp ${_order.dp.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Sisa Lunas: Rp ${(_order.finalPrice - _order.dp).clamp(0, double.infinity).toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 12),

                  // Informasi Tanggal
                  const Text('Informasi Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                  const Divider(),
                  Text('Tanggal Order: ${_order.createdAt.day}/${_order.createdAt.month}/${_order.createdAt.year}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Tanggal Ambil: ${_order.pickupDate != null ? "${_order.pickupDate!.day}/${_order.pickupDate!.month}/${_order.pickupDate!.year}" : "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  Text('Tanggal Jadi: ${_order.readyDate != null ? "${_order.readyDate!.day}/${_order.readyDate!.month}/${_order.readyDate!.year}" : "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                  const SizedBox(height: 12),

                  // Gambar Referensi
                  const Text('Referensi Gambar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ..._order.imagePaths.map((img) => Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber),
                            image: DecorationImage(
                              image: img.startsWith('http') ? NetworkImage(img) : AssetImage('assets/images/no_image.png') as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Catatan
                  const Text('Catatan (Memo)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Text(_order.notes, style: const TextStyle(fontFamily: 'Courier', fontSize: 14)),
                  ),

                  // Status
                  const SizedBox(height: 8),
                  Text('Status: ${_order.workflowStatus.label}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),


                  // Tombol Terima Pesanan
                  if (_order.workflowStatus == OrderWorkflowStatus.waitingInventory) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Terima Pesanan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              setState(() => _isProcessing = true);
                              try {
                                final updatedOrder = _order.copyWith(
                                  workflowStatus: OrderWorkflowStatus.inventory,
                                );
                                await OrderService().updateOrder(updatedOrder);
                                await _fetchOrderDetail();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pesanan diterima, status menjadi Inventory')),
                                );
                                Navigator.of(context).pop(true);
                              } finally {
                                setState(() => _isProcessing = false);
                              }
                            },
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('Input Data Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                            onChanged: (val) => inventoryProductId = val,
                            validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: jewelryTypes.contains(inventoryJewelryType) ? inventoryJewelryType : null,
                            items: jewelryTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            decoration: const InputDecoration(labelText: 'Jenis Perhiasan *'),
                            onChanged: (val) {
                              setState(() {
                                inventoryJewelryType = val;
                                if (!_isRingType) inventoryRingSize = null;
                              });
                            },
                            validator: (val) => (val == null || val.isEmpty) ? 'Wajib dipilih' : null,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: goldColors.contains(inventoryGoldColor) ? inventoryGoldColor : null,
                            items: goldColors.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            decoration: const InputDecoration(labelText: 'Warna Emas *'),
                            onChanged: (val) => setState(() => inventoryGoldColor = val),
                            validator: (val) => (val == null || val.isEmpty) ? 'Wajib dipilih' : null,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: goldTypes.contains(inventoryGoldType) ? inventoryGoldType : null,
                            items: goldTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            decoration: const InputDecoration(labelText: 'Jenis Emas *'),
                            onChanged: (val) => setState(() => inventoryGoldType = val),
                            validator: (val) => (val == null || val.isEmpty) ? 'Wajib dipilih' : null,
                          ),
                          const SizedBox(height: 8),
                          _buildStoneList(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Upload Foto *'),
                                onPressed: _pickImages,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                inventoryImageFiles.isNotEmpty
                                    ? '${inventoryImageFiles.length} foto dipilih'
                                    : 'Belum ada foto',
                                style: TextStyle(
                                  color: inventoryImageFiles.isNotEmpty ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          if (inventoryImageFiles.isNotEmpty)
                            SizedBox(
                              height: 80,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: inventoryImageFiles
                                    .map((f) => Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Image.file(f, width: 70, height: 70, fit: BoxFit.cover),
                                        ))
                                    .toList(),
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
                          // Remove dots and parse to double
                          final cleanVal = val.replaceAll('.', '').replaceAll('Rp ', '').trim();
                          inventoryItemsPrice = double.tryParse(cleanVal);
                        },
                        validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                      ),
                          if (_isRingType)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextFormField(
                                initialValue: inventoryRingSize,
                                decoration: const InputDecoration(labelText: 'Ukuran Cincin *'),
                                onChanged: (val) => inventoryRingSize = val,
                                validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                              ),
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isProcessing || !_canSubmit ? null : _updateInventory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: _isProcessing
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Simpan Data Inventory'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _isProcessing || !_canSubmit || !_inventorySaved ? null : _submitToFinishing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: _isProcessing
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Submit ke Finishing'),
                          ),
                          const SizedBox(height: 8),

                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}