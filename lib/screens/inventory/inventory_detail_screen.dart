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
  const InventoryDetailScreen({super.key, this.order, this.inventoryItem});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  Order? _order;
  InventoryItem? _inventoryItem;
  // Inventory form fields
  final _formKey = GlobalKey<FormState>();
  String? inventoryProductId;
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
    if (widget.inventoryItem != null) {
      _inventoryItem = widget.inventoryItem;
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
      final refreshedOrder = await OrderService().getOrderById(widget.order!.id);
      setState(() {
        _order = refreshedOrder;
        // Prefill jika sudah ada data inventory
        inventoryProductId = _order?.inventoryProductId;
        inventoryJewelryType = _order?.inventoryJewelryType;
        inventoryGoldColor = _order?.inventoryGoldColor;
        inventoryGoldType = _order?.inventoryGoldType;
        inventoryStoneUsed = List<Map<String, dynamic>>.from(_order?.inventoryStoneUsed ?? []);
        inventoryImageFiles = (_order?.inventoryImagePaths ?? []).map((p) => File(p)).toList();
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
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        inventoryImageFiles = picked.map((x) => File(x.path)).toList();
      });
    }
  }

  Future<void> _pickInventoryImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      List<String> urls = [];
      for (final img in picked) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.187.174/sumatra_api/upload_inventory_image.php'),
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
      });
    }
  }

  bool get _isRingType =>
      inventoryJewelryType == 'Ring' ||
      inventoryJewelryType == 'Men Ring' ||
      inventoryJewelryType == 'Women Ring';

  bool get _canSubmit {
    // Semua field wajib harus terisi, KECUALI inventoryStoneUsed
    return inventoryProductId != null && inventoryProductId!.isNotEmpty &&
        inventoryJewelryType != null && inventoryJewelryType!.isNotEmpty &&
        inventoryGoldColor != null && inventoryGoldColor!.isNotEmpty &&
        inventoryGoldType != null && inventoryGoldType!.isNotEmpty &&
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
        workflowStatus: OrderWorkflowStatus.waitingSalesCompletion, // langsung update status
      );
      await OrderService().updateOrder(updatedOrder);
      final response = await http.post(
        Uri.parse('http://192.168.187.174/sumatra_api/update_inventory.php'),
        body: {
          'order_id': _order!.id,
          'product_id': inventoryProductId ?? '',
          'jewelry_type': inventoryJewelryType ?? '',
          'gold_color': inventoryGoldColor ?? '',
          'gold_type': inventoryGoldType ?? '',
          'stone_used': jsonEncode(inventoryStoneUsed),
          'image_paths': jsonEncode(inventoryImageUrls),
          'items_price': inventoryItemsPrice?.toString() ?? '',
          'ring_size': inventoryRingSize ?? '',
        },
      );
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        setState(() {
          _inventorySaved = true;
        });
        await _fetchOrderDetail(); // refresh data
        // Prefill field form dengan data terbaru
        setState(() {
          inventoryProductId = _order!.inventoryProductId;
          inventoryJewelryType = _order!.inventoryJewelryType;
          inventoryGoldColor = _order!.inventoryGoldColor;
          inventoryGoldType = _order!.inventoryGoldType;
          inventoryStoneUsed = List<Map<String, dynamic>>.from(_order!.inventoryStoneUsed ?? []);
          inventoryImageUrls = List<String>.from(_order!.inventoryImagePaths ?? []);
          inventoryItemsPrice = _order!.inventoryItemsPrice;
          inventoryRingSize = _order!.inventoryRingSize;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data inventory berhasil disimpan & status lanjut ke Sales Completion')),
        );
        Navigator.of(context).pop(true); // langsung kembali dan refresh dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update inventory: \\${result['error']}')),
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
                      validator: (val) => inventoryStoneUsed.isEmpty ? null : (val == null || val.isEmpty ? 'Pilih bentuk' : null),
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
                      validator: (val) => inventoryStoneUsed.isEmpty ? null : ((val == null || val.isEmpty)
                          ? 'Isi'
                          : (int.tryParse(val) == null || int.tryParse(val)! <= 0)
                              ? 'Harus > 0'
                              : null),
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
                      validator: (val) => inventoryStoneUsed.isEmpty ? null : ((val == null || val.isEmpty)
                          ? 'Isi'
                          : (double.tryParse(val) == null || double.tryParse(val)! <= 0)
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
    final isWorking = _order?.workflowStatus == OrderWorkflowStatus.inventory;
    final isInventoryView = _order?.workflowStatus == OrderWorkflowStatus.waitingSalesCompletion;

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Jika inventoryItem, tampilkan detail inventory
    if (_inventoryItem != null) {
      final item = _inventoryItem!;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Inventory'),
          backgroundColor: const Color(0xFFD4AF37),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imagePaths.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item.imagePaths.first,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 180,
                        height: 180,
                        color: Colors.brown[100],
                        child: const Icon(Icons.image, size: 60, color: Colors.brown),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text('ID Produk: ${item.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Jenis Perhiasan: ${item.jewelryType}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Jenis Emas: ${item.goldType}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Warna Emas: ${item.goldColor}', style: const TextStyle(fontSize: 16)),
              if (item.ringSize != null && item.ringSize!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Ring Size: ${item.ringSize}', style: const TextStyle(fontSize: 16)),
              ],
              const SizedBox(height: 8),
              if (item.itemsPrice != null) ...[
                Text('Harga: Rp ${item.itemsPrice?.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
              ],
              Text('Tanggal Input: ${item.createdAt ?? '-'}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              if (item.stoneUsed != null && item.stoneUsed!.isNotEmpty) ...[
                Text('Batu yang digunakan:', style: const TextStyle(fontSize: 16)),
                ...item.stoneUsed!.map((stone) => Text('- ${stone['name'] ?? '-'}', style: const TextStyle(fontSize: 15))),
                const SizedBox(height: 8),
              ],
              if (item.imagePaths.length > 1) ...[
                const Text('Foto Lainnya:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: item.imagePaths.skip(1).map((img) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      img,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.brown[100],
                        child: const Icon(Icons.image, size: 30, color: Colors.brown),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 8),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: isInventoryView
                  ? ListView(
                      children: [
                        const Text('Data Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                        const Divider(),
                        Text('Product ID: ${_order!.inventoryProductId ?? "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Jenis Perhiasan: ${_order!.inventoryJewelryType ?? "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Jenis Emas: ${_order!.inventoryGoldType ?? "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Warna Emas: ${_order!.inventoryGoldColor ?? "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Ukuran Cincin: ${_order!.inventoryRingSize ?? "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Harga Barang Akhir: Rp ${_order!.inventoryItemsPrice?.toStringAsFixed(0) ?? "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Tanggal Input Inventory: ${_order!.updatedAt != null ? '${_order!.updatedAt!.day}/${_order!.updatedAt!.month}/${_order!.updatedAt!.year}' : '-'}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        const SizedBox(height: 12),
                        const Text('Foto Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 90,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...?_order!.inventoryImagePaths?.map((img) => Container(
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
                        const Text('Batu yang Digunakan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                        if ((_order!.inventoryStoneUsed ?? []).isEmpty)
                          const Text('Tidak ada data batu.'),
                        ...?_order!.inventoryStoneUsed?.map((stone) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Bentuk: ${stone['shape'] ?? "-"}, Jumlah: ${stone['count'] ?? "-"}, Carat: ${stone['carat'] ?? "-"}',
                                style: const TextStyle(color: Color(0xFF7C5E2C)),
                              ),
                            )),
                      ],
                    )
                  : ListView(
                      children: [
                        // Informasi Pelanggan
                        const Text('Informasi Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                        const Divider(),
                        Text('Nama: ${_order!.customerName}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Kontak: ${_order!.customerContact}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Alamat: ${_order!.address}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        const SizedBox(height: 12),

                        // Informasi Barang
                        const Text('Informasi Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                        const Divider(),
                        Text('Jenis Perhiasan: ${_order!.jewelryType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Jenis Emas: ${_order!.goldType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Warna Emas: ${_order!.goldColor}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Ukuran Cincin: ${_order!.ringSize}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Tipe Batu: ${_order!.stoneType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Ukuran Batu: ${_order!.stoneSize}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        const SizedBox(height: 12),

                        // Informasi Harga
                        const Text('Informasi Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                        const Divider(),
                        Text('Harga Perkiraan: Rp ${_order!.finalPrice.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Harga Emas per Gram: Rp ${_order!.goldPricePerGram.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('DP: Rp ${_order!.dp.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Sisa Lunas: Rp ${(_order!.finalPrice - _order!.dp).clamp(0, double.infinity).toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent)),
                        const SizedBox(height: 12),

                        // Informasi Tanggal
                        const Text('Informasi Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                        const Divider(),
                        Text('Tanggal Order: ${_order!.createdAt.day}/${_order!.createdAt.month}/${_order!.createdAt.year}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Tanggal Ambil: ${_order!.pickupDate != null ? "${_order!.pickupDate!.day}/${_order!.pickupDate!.month}/${_order!.pickupDate!.year}" : "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        Text('Tanggal Jadi: ${_order!.readyDate != null ? "${_order!.readyDate!.day}/${_order!.readyDate!.month}/${_order!.readyDate!.year}" : "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
                        const SizedBox(height: 12),

                        // Gambar Referensi
                        const Text('Referensi Gambar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 90,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ..._order!.imagePaths.map((img) => Container(
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
                          child: Text(_order!.notes, style: const TextStyle(fontFamily: 'Courier', fontSize: 14)),
                        ),

                        // Status
                        if (!isInventoryView) ...[
                          const SizedBox(height: 8),
                          Text('Status: ${_order!.workflowStatus.label}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                        ],


                        // Tombol Terima Pesanan
                        if (_order!.workflowStatus == OrderWorkflowStatus.waitingInventory) ...[
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
                                      final updatedOrder = _order!.copyWith(
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
                                      onPressed: _pickInventoryImages,
                                      icon: const Icon(Icons.add_a_photo),
                                      label: const Text('Upload Foto Inventory'),
                                    ),
                                  ],
                                ),
                                if ((inventoryImageUrls).isNotEmpty)
                                  SizedBox(
                                    height: 80,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: (inventoryImageUrls)
                                          .map((img) => Padding(
                                                padding: const EdgeInsets.all(4),
                                                child: Image.network(
                                                  img,
                                                  width: 70,
                                                  height: 70,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset('assets/images/no_image.png', width: 70, height: 70, fit: BoxFit.cover);
                                                  },
                                                ),
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
                              ],
                            ),
                          ),
                  ],
                ),
            ),
    );
  }
}