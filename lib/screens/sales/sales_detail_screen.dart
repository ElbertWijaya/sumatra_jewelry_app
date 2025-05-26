import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesDetailScreen extends StatefulWidget {
  final Order order;
  const SalesDetailScreen({super.key, required this.order});

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  late Order _order;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _stoneSizeController;
  late TextEditingController _ringSizeController;
  late TextEditingController _notesController;
  late TextEditingController _goldPriceController;
  late TextEditingController _dateController;

  late List<String> _images;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  DateTime? _readyDate;

  // Dropdown values
  String? _jewelryType;
  String? _goldColor;
  String? _goldType;
  String? _stoneType;

  final ImagePicker _picker = ImagePicker();

  // Pilihan dropdown (gunakan sama dengan SalesCreateScreen)
  final List<String> jewelryTypes = [
    "ring",
    "bangle",
    "earring",
    "pendant",
    "hairpin",
    "pin",
    "men ring",
    "women ring",
    "engagement ring",
    "custom",
  ];
  final List<String> goldColors = ["White Gold", "Rose Gold", "Yellow Gold"];
  final List<String> goldTypes = ["19K", "18K", "14K", "9K"];
  final List<String> stoneTypes = [
    "Opal",
    "Sapphire",
    "Jade",
    "Emerald",
    "Ruby",
    "Amethyst",
    "Diamond",
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _images = List<String>.from(_order.imagePaths ?? []);
    _nameController = TextEditingController(text: _order.customerName);
    _contactController = TextEditingController(text: _order.customerContact);
    _addressController = TextEditingController(text: _order.address);
    _stoneSizeController = TextEditingController(text: _order.stoneSize ?? "");
    _ringSizeController = TextEditingController(text: _order.ringSize ?? "");
    _goldPriceController = TextEditingController(
      text: _order.goldPricePerGram?.toString() ?? "",
    );
    _notesController = TextEditingController(text: _order.notes ?? "");
    _readyDate = _order.readyDate;
    _dateController = TextEditingController(
      text:
          _readyDate == null
              ? ""
              : "${_readyDate!.day}/${_readyDate!.month}/${_readyDate!.year}",
    );

    // Dropdown values
    _jewelryType = _order.jewelryType.isNotEmpty ? _order.jewelryType : null;
    _goldColor = _order.goldColor;
    _goldType = _order.goldType;
    _stoneType = _order.stoneType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _stoneSizeController.dispose();
    _ringSizeController.dispose();
    _goldPriceController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images.map((x) => x.path));
      });
    }
  }

  void _removeImage(int idx) {
    setState(() {
      _images.removeAt(idx);
    });
  }

  Future<void> _saveEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updatedOrder = _order.copyWith(
      customerName: _nameController.text,
      customerContact: _contactController.text,
      address: _addressController.text,
      jewelryType: _jewelryType ?? '',
      goldColor: _goldColor,
      goldType: _goldType,
      stoneType: _stoneType,
      stoneSize:
          _stoneSizeController.text.isEmpty ? null : _stoneSizeController.text,
      ringSize:
          _ringSizeController.text.isEmpty ? null : _ringSizeController.text,
      goldPricePerGram: double.tryParse(_goldPriceController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      readyDate: _readyDate,
      imagePaths: _images,
    );

    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _order = updatedOrder;
        // Sync dropdowns after update
        _jewelryType =
            updatedOrder.jewelryType.isNotEmpty
                ? updatedOrder.jewelryType
                : null;
        _goldColor = updatedOrder.goldColor;
        _goldType = updatedOrder.goldType;
        _stoneType = updatedOrder.stoneType;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil diperbarui!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update pesanan: $e')));
    }
    setState(() => _isSaving = false);
  }

  Future<void> _deleteOrder() async {
    setState(() => _isDeleting = true);
    try {
      await OrderService().deleteOrder(_order.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dihapus!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus pesanan: $e')));
    }
    setState(() => _isDeleting = false);
  }

  void _showDeleteConfirmationDialog() {
    bool checked = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Hapus Pesanan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Apakah kamu yakin untuk menghapus pesanan ini?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: checked,
                        onChanged: (v) {
                          setStateDialog(() {
                            checked = v ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Saya yakin ingin menghapus pesanan ini',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      _isDeleting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed:
                      checked && !_isDeleting
                          ? () async {
                            Navigator.of(context).pop();
                            await _deleteOrder();
                          }
                          : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child:
                      _isDeleting
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Iya'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selesaikanPesanan() async {
    setState(() => _isSaving = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.done,
    );
    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil diselesaikan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyelesaikan pesanan: $e')),
      );
    }
    setState(() => _isSaving = false);
  }

  Future<void> _submitToDesigner() async {
    setState(() => _isSaving = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.waiting_designer,
    );
    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dikirim ke designer!')),
      );
      Navigator.of(context).pop(true); // Refresh dashboard
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal submit ke designer: $e')));
    }
    setState(() => _isSaving = false);
  }

  String showField(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Belum diisi' : value;
  String showDouble(double? value) =>
      value == null ? 'Belum diisi' : value.toString();
  String showDate(DateTime? date) =>
      date == null ? 'Belum diisi' : "${date.day}/${date.month}/${date.year}";

  Widget _buildDisplayField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Helper to build checklist progress section for each step
  Widget buildChecklistSection(
    String title,
    List<String> todoList,
    List<String>? checkedList,
  ) {
    if (checkedList == null || checkedList.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title Progress:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ...todoList.map(
            (name) => Row(
              children: [
                Icon(
                  checkedList.contains(name)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color:
                      checkedList.contains(name) ? Colors.green : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(name),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define each role's todoList sesuai implementasi di detail screen masing-masing role
    const designerTodo = [
      "Design",
      "Print",
      "Pengecekan",
    ]; // Sesuaikan dengan checklist designer
    const corTodo = [
      "Susun lilin",
      "Terima emas",
      "Cor",
    ]; // Checklist cor/casting
    const carverTodo = [
      "Bom",
      "Polish",
      "Getar",
      "Kasih ke Olivia",
    ]; // Checklist carver
    const diamondSetterTodo = [
      "Pilih batu",
      "Pasang batu",
      "Kasih ke Olivia",
    ]; // Checklist diamond setter
    const finisherTodo = ["Finishing"]; // Checklist finisher

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        actions:
            [
              (!_isEditing &&
                      _order.workflowStatus ==
                          OrderWorkflowStatus.waiting_sales_check)
                  ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => _isEditing = true),
                  )
                  : !_isEditing
                  ? null
                  : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _isEditing = false),
                  ),
            ].whereType<Widget>().toList(),
      ),
      body:
          _isSaving
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child:
                    !_isEditing
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar referensi
                            if (_images.isNotEmpty)
                              SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images.length,
                                  itemBuilder: (context, idx) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_images[idx]),
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (c, e, s) => Container(
                                                width: 110,
                                                height: 110,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 16),
                            _buildDisplayField(
                              'Nama Pelanggan',
                              showField(_order.customerName),
                            ),
                            _buildDisplayField(
                              'Nomor Telepon',
                              showField(_order.customerContact),
                            ),
                            _buildDisplayField(
                              'Alamat',
                              showField(_order.address),
                            ),
                            _buildDisplayField(
                              'Jenis Perhiasan',
                              showField(_order.jewelryType),
                            ),
                            _buildDisplayField(
                              'Warna Emas',
                              showField(_order.goldColor),
                            ),
                            _buildDisplayField(
                              'Jenis Emas',
                              showField(_order.goldType),
                            ),
                            _buildDisplayField(
                              'Jenis Batu',
                              showField(_order.stoneType),
                            ),
                            _buildDisplayField(
                              'Ukuran Batu',
                              showField(_order.stoneSize),
                            ),
                            _buildDisplayField(
                              'Ukuran Cincin',
                              showField(_order.ringSize),
                            ),
                            _buildDisplayField(
                              'Harga Emas/Gram',
                              showDouble(_order.goldPricePerGram),
                            ),
                            _buildDisplayField(
                              'Catatan Tambahan',
                              showField(_order.notes),
                            ),
                            _buildDisplayField(
                              'Tanggal Siap',
                              showDate(_order.readyDate),
                            ),
                            _buildDisplayField(
                              'Status',
                              _order.workflowStatus.label,
                            ),
                            // Progress section for each process
                            buildChecklistSection(
                              "Designer",
                              designerTodo,
                              _order.designerWorkChecklist,
                            ),
                            buildChecklistSection(
                              "Cor",
                              corTodo,
                              _order.castingWorkChecklist,
                            ),
                            buildChecklistSection(
                              "Carver",
                              carverTodo,
                              _order.carvingWorkChecklist,
                            ),
                            buildChecklistSection(
                              "Diamond Setter",
                              diamondSetterTodo,
                              _order.stoneSettingWorkChecklist,
                            ),
                            buildChecklistSection(
                              "Finisher",
                              finisherTodo,
                              _order.finishingWorkChecklist,
                            ),
                            _buildDisplayField(
                              'Designer',
                              showField(_order.assignedDesigner),
                            ),
                            _buildDisplayField(
                              'Caster',
                              showField(_order.assignedCaster),
                            ),
                            _buildDisplayField(
                              'Carver',
                              showField(_order.assignedCarver),
                            ),
                            _buildDisplayField(
                              'Diamond Setter',
                              showField(_order.assignedDiamondSetter),
                            ),
                            _buildDisplayField(
                              'Finisher',
                              showField(_order.assignedFinisher),
                            ),
                            _buildDisplayField(
                              'Inventory',
                              showField(_order.assignedInventory),
                            ),
                            const SizedBox(height: 24),
                            if (_order.workflowStatus ==
                                OrderWorkflowStatus.waiting_sales_check)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isSaving ? null : _submitToDesigner,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'Submit ke Designer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (_order.workflowStatus ==
                                OrderWorkflowStatus.waiting_sales_completion)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isSaving ? null : _selesaikanPesanan,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'Selesaikan Pesanan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed:
                                  _isDeleting
                                      ? null
                                      : _showDeleteConfirmationDialog,
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        )
                        : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Referensi Gambar',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images.length + 1,
                                  itemBuilder: (context, idx) {
                                    if (idx == _images.length) {
                                      return Container(
                                        width: 110,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: OutlinedButton(
                                          onPressed: _pickImages,
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_a_photo, size: 32),
                                              SizedBox(height: 8),
                                              Text(
                                                'Tambah\nGambar',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              File(_images[idx]),
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (c, e, s) => Container(
                                                    width: 110,
                                                    height: 110,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(idx),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Pelanggan',
                                ),
                                validator:
                                    (v) =>
                                        (v == null || v.isEmpty)
                                            ? 'Wajib diisi'
                                            : null,
                              ),
                              TextFormField(
                                controller: _contactController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Nomor Telepon',
                                ),
                                keyboardType: TextInputType.phone,
                                validator:
                                    (v) =>
                                        (v == null || v.isEmpty)
                                            ? 'Wajib diisi'
                                            : null,
                              ),
                              TextFormField(
                                controller: _addressController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Alamat',
                                ),
                                validator:
                                    (v) =>
                                        (v == null || v.isEmpty)
                                            ? 'Wajib diisi'
                                            : null,
                              ),
                              DropdownButtonFormField<String>(
                                value: _jewelryType,
                                decoration: const InputDecoration(
                                  labelText: "Jenis Perhiasan *",
                                ),
                                items:
                                    jewelryTypes
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                validator:
                                    (v) =>
                                        (v == null || v.isEmpty)
                                            ? 'Wajib dipilih'
                                            : null,
                                onChanged:
                                    _isEditing
                                        ? (val) =>
                                            setState(() => _jewelryType = val)
                                        : null,
                              ),
                              DropdownButtonFormField<String>(
                                value: _goldColor,
                                decoration: const InputDecoration(
                                  labelText: "Warna Emas",
                                ),
                                items:
                                    goldColors
                                        .map(
                                          (color) => DropdownMenuItem(
                                            value: color,
                                            child: Text(color),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    _isEditing
                                        ? (val) =>
                                            setState(() => _goldColor = val)
                                        : null,
                              ),
                              DropdownButtonFormField<String>(
                                value: _goldType,
                                decoration: const InputDecoration(
                                  labelText: "Jenis Emas",
                                ),
                                items:
                                    goldTypes
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    _isEditing
                                        ? (val) =>
                                            setState(() => _goldType = val)
                                        : null,
                              ),
                              DropdownButtonFormField<String>(
                                value: _stoneType,
                                decoration: const InputDecoration(
                                  labelText: "Jenis Batu",
                                ),
                                items:
                                    stoneTypes
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    _isEditing
                                        ? (val) =>
                                            setState(() => _stoneType = val)
                                        : null,
                              ),
                              TextFormField(
                                controller: _stoneSizeController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Ukuran Batu',
                                ),
                              ),
                              TextFormField(
                                controller: _ringSizeController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Ukuran Cincin',
                                ),
                              ),
                              TextFormField(
                                controller: _goldPriceController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Harga Emas/Gram',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              TextFormField(
                                controller: _notesController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Catatan Tambahan',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _dateController,
                                enabled: false,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Tanggal Siap',
                                  suffixIcon:
                                      _isEditing
                                          ? IconButton(
                                            icon: const Icon(
                                              Icons.calendar_today,
                                            ),
                                            onPressed: () async {
                                              final picked =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        _readyDate ??
                                                        DateTime.now(),
                                                    firstDate: DateTime(2020),
                                                    lastDate: DateTime(2100),
                                                  );
                                              if (picked != null) {
                                                setState(() {
                                                  _readyDate = picked;
                                                  _dateController.text =
                                                      "${picked.day}/${picked.month}/${picked.year}";
                                                });
                                              }
                                            },
                                          )
                                          : const Icon(Icons.calendar_today),
                                ),
                                onTap:
                                    !_isEditing
                                        ? null
                                        : () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate:
                                                _readyDate ?? DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              _readyDate = picked;
                                              _dateController.text =
                                                  "${picked.day}/${picked.month}/${picked.year}";
                                            });
                                          }
                                        },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isSaving ? null : _saveEdit,
                                      child: const Text('Simpan Perubahan'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed:
                                        _isDeleting
                                            ? null
                                            : _showDeleteConfirmationDialog,
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
              ),
    );
  }
}
