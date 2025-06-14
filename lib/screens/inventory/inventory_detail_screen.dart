import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import '../../models/order.dart';
import '../../models/inventory.dart';
import '../../services/order_service.dart';
import '../../services/inventory_service.dart';
import '../../utils/thousand_separator_input_formatter.dart';

class InventoryDetailScreen extends StatefulWidget {
  final Order order;
  const InventoryDetailScreen({super.key, required this.order});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  Order _order = Order(
    id: '',
    customerName: '',
    customerContact: '',
    address: '',
    jewelryType: '',
    createdAt: DateTime.now(),
  );

  final _formKey = GlobalKey<FormState>();
  String? productId;
  String? jewelryType;
  String? goldColor;
  String? goldType;
  List<Map<String, String>> stoneUsed = [];
  String? ringSize;
  List<String> imagePaths = [];
  double? itemsPrice;

  final TextEditingController _itemsPriceController = TextEditingController();

  bool _isProcessing = false;
  bool _isLoading = true;
  bool _canSubmitToSales = false;

  final List<String> _jewelryTypes = [
    'Bangle', 'Ring', 'Earrings', 'Necklace', 'Bracelet', 'Pendant', 'Other'
  ];
  final List<String> _goldColors = [
    'White Gold', 'Rose Gold', 'Yellow Gold'
  ];
  final List<String> _goldTypes = [
    '24K', '22K', '18K', '14K', '10K', '9K'
  ];
  final List<String> _stoneShapes = [
    'Round', 'Princess', 'Oval', 'Marquise', 'Pear', 'Cushion', 'Emerald', 'Asscher', 'Radiant', 'Heart', 'Trillion', 'Baguette', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    productId = _order.productId;
    jewelryType = _order.jewelryType.isNotEmpty ? _order.jewelryType : null;
    goldColor = _order.goldColor.isNotEmpty ? _order.goldColor : null;
    goldType = _goldTypes.firstWhere(
      (e) => e.toLowerCase() == _order.goldType.toLowerCase(),
      orElse: () => '',
    );
    if (goldType == '') goldType = null;
    ringSize = _order.ringSize;
    imagePaths = List<String>.from(_order.imagePaths ?? []);
    itemsPrice = _order.finalPrice;
    _itemsPriceController.text = itemsPrice != null && itemsPrice! > 0
        ? NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(itemsPrice)
        : '';
    if (_order.stoneUsed != null) {
      stoneUsed = List<Map<String, String>>.from(_order.stoneUsed);
    }
    _isLoading = false;
  }

  void _addStone() {
    setState(() {
      stoneUsed.add({'type': '', 'qty': '', 'size': ''});
    });
  }

  void _removeStone(int index) {
    setState(() {
      stoneUsed.removeAt(index);
    });
  }

  Future<void> _saveInventory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    try {
      // Simpan ke table inventory
      final inventory = Inventory(
        id: _order.id,
        orderId: _order.id,
        productId: productId ?? '',
        jewelryType: jewelryType ?? '',
        goldType: goldType ?? '',
        goldColor: goldColor ?? '',
        ringSize: ringSize ?? '',
        itemsPrice: itemsPrice ?? 0,
        imagePaths: imagePaths,
        stoneUsed: stoneUsed,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      await InventoryService().insertInventory(inventory);

      // Update order status (jika perlu)
      final updatedOrder = _order.copyWith(
        workflowStatus: OrderWorkflowStatus.inventory,
      );
      await OrderService().updateOrder(updatedOrder);

      setState(() {
        _canSubmitToSales = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data inventory berhasil disimpan')),
      );
      Navigator.of(context).pop(true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePaths.add(pickedFile.path);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      imagePaths.removeAt(index);
    });
  }

  @override
  void dispose() {
    _itemsPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringTypes = ['ring', 'mens ring', 'women ring'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Inventory'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Product ID
                    TextFormField(
                      initialValue: productId,
                      decoration: const InputDecoration(labelText: 'Product ID'),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      onChanged: (v) => productId = v,
                    ),
                    const SizedBox(height: 12),
                    // Jewelry Type (Dropdown)
                    DropdownButtonFormField<String>(
                      value: jewelryType,
                      decoration: const InputDecoration(labelText: 'Jenis Perhiasan'),
                      items: _jewelryTypes
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) => setState(() => jewelryType = val),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 12),
                    // Gold Color (Dropdown)
                    DropdownButtonFormField<String>(
                      value: goldColor,
                      decoration: const InputDecoration(labelText: 'Warna Emas'),
                      items: _goldColors
                          .map((color) => DropdownMenuItem(value: color, child: Text(color)))
                          .toList(),
                      onChanged: (val) => setState(() => goldColor = val),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 12),
                    // Gold Type (Dropdown)
                    DropdownButtonFormField<String>(
                      value: goldType,
                      decoration: const InputDecoration(labelText: 'Jenis Emas'),
                      items: _goldTypes
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) => setState(() => goldType = val),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 12),
                    // Stone Used (multiple)
                    const Text('Bentuk Batu', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...stoneUsed.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final stone = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: stone['type'] != null && _stoneShapes.contains(stone['type']) ? stone['type'] : null,
                              decoration: const InputDecoration(labelText: 'Bentuk Batu'),
                              items: _stoneShapes
                                  .map((shape) => DropdownMenuItem(value: shape, child: Text(shape)))
                                  .toList(),
                              onChanged: (val) => setState(() => stoneUsed[idx]['type'] = val ?? ''),
                              validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              initialValue: stone['qty'],
                              decoration: const InputDecoration(labelText: 'Jumlah'),
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                              onChanged: (v) => stoneUsed[idx]['qty'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              initialValue: stone['size']?.replaceAll(' (ct)', ''),
                              decoration: const InputDecoration(
                                labelText: 'Ukuran',
                                suffixText: '(ct)',
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^[0-9.,]*$')),
                              ],
                              validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                              onChanged: (v) {
                                String clean = v.replaceAll(' (ct)', '').trim();
                                if (clean.isNotEmpty) {
                                  stoneUsed[idx]['size'] = '$clean (ct)';
                                } else {
                                  stoneUsed[idx]['size'] = '';
                                }
                                setState(() {});
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeStone(idx),
                          ),
                        ],
                      );
                    }),
                    TextButton.icon(
                      onPressed: _addStone,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Batu'),
                    ),
                    const SizedBox(height: 12),
                    // Ring Size (only for ring types)
                    if (jewelryType != null && ringTypes.any((t) => jewelryType!.toLowerCase().contains(t)))
                      TextFormField(
                        initialValue: ringSize,
                        decoration: const InputDecoration(labelText: 'Ring Size'),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        onChanged: (v) => ringSize = v,
                      ),
                    const SizedBox(height: 12),
                    // Image Paths (must upload at least one)
                    const Text('Upload Gambar (wajib)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...imagePaths.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final img = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Image.file(
                            File(img),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          ),
                          title: Text('Gambar ${idx + 1}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeImage(idx),
                          ),
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Tambah Gambar'),
                    ),
                    if (imagePaths.isEmpty)
                      const Text('Minimal 1 gambar harus diupload', style: TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    // Items Price
                    TextFormField(
                      controller: _itemsPriceController,
                      decoration: const InputDecoration(labelText: 'Harga Barang (Rp)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandSeparatorInputFormatter()],
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      onChanged: (v) {
                        final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
                        itemsPrice = double.tryParse(clean);
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _saveInventory,
                      child: _isProcessing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Simpan Data Inventory'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _canSubmitToSales ? () {
                        // TODO: Implement submit ke sales
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Submit ke Sales berhasil!')),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit ke Sales'),
                    ),
                    const SizedBox(height: 24),
                    // Checklist Worklist Inventory
                    if (_canSubmitToSales)
                      InventoryTaskScreen(order: _order),
                  ],
                ),
              ),
            ),
    );
  }
}

// Tambahkan widget checklist worklist inventory
class InventoryTaskScreen extends StatefulWidget {
  final Order order;
  const InventoryTaskScreen({super.key, required this.order});

  @override
  State<InventoryTaskScreen> createState() => _InventoryTaskScreenState();
}

class _InventoryTaskScreenState extends State<InventoryTaskScreen> {
  List<String> _inventoryChecklist = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _inventoryChecklist = List<String>.from(widget.order.inventoryWorkChecklist ?? []);
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = widget.order.copyWith(
        inventoryWorkChecklist: _inventoryChecklist,
      );
      await OrderService().updateOrder(updatedOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist berhasil diupdate')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tasks = [
      'Cek stok',
      'Input data inventory',
      'Foto produk',
      'Verifikasi kualitas',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Checklist Worklist Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
        ...tasks.map((task) => CheckboxListTile(
              value: _inventoryChecklist.contains(task),
              title: Text(task),
              onChanged: _isProcessing
                  ? null
                  : (val) {
                      setState(() {
                        if (val == true) {
                          if (!_inventoryChecklist.contains(task)) {
                            _inventoryChecklist.add(task);
                          }
                        } else {
                          _inventoryChecklist.remove(task);
                        }
                      });
                    },
            )),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _isProcessing ? null : _updateChecklist,
          child: _isProcessing
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Update Checklist'),
        ),
      ],
    );
  }
}