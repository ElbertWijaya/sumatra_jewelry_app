import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesDetailScreen extends StatefulWidget {
  final Order order;
  const SalesDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  late Order _order;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _jewelryTypeController;
  late TextEditingController _stoneTypeController;
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

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _images = List<String>.from(_order.imagePaths ?? []);
    _nameController = TextEditingController(text: _order.customerName);
    _contactController = TextEditingController(text: _order.customerContact);
    _addressController = TextEditingController(text: _order.address);
    _jewelryTypeController = TextEditingController(text: _order.jewelryType);
    _stoneTypeController = TextEditingController(text: _order.stoneType ?? "");
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _jewelryTypeController.dispose();
    _stoneTypeController.dispose();
    _stoneSizeController.dispose();
    _ringSizeController.dispose();
    _goldPriceController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
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
      jewelryType: _jewelryTypeController.text,
      stoneType: _stoneTypeController.text,
      stoneSize: _stoneSizeController.text,
      ringSize: _ringSizeController.text,
      goldPricePerGram: double.tryParse(_goldPriceController.text),
      notes: _notesController.text,
      readyDate: _readyDate,
      imagePaths: _images,
    );

    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil diperbarui!')),
      );
      Navigator.of(context).pop(true);
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
                    'Apakah kamu yakin untuk menghapus pesanan ini??',
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

  // Tambahan: Fungsi untuk menyelesaikan pesanan, hanya jika status waiting_sales_completion
  Future<void> _selesaikanPesanan() async {
    setState(() => _isSaving = true);
    final updatedOrder = _order.copyWith(workflowStatus: OrderWorkflowStatus.done);
    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil diselesaikan!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyelesaikan pesanan: $e')),
      );
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        actions: [
          !_isEditing
              ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
              )
              : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _isEditing = false),
              ),
        ],
      ),
      body:
          _isSaving
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar referensi
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Referensi Gambar',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length + (_isEditing ? 1 : 0),
                          itemBuilder: (context, idx) {
                            if (_isEditing && idx == _images.length) {
                              return Container(
                                width: 110,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: OutlinedButton(
                                  onPressed: _pickImages,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                ),
                                if (_isEditing)
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
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
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
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                      TextFormField(
                        controller: _addressController,
                        enabled: _isEditing,
                        decoration: const InputDecoration(labelText: 'Alamat'),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                      TextFormField(
                        controller: _jewelryTypeController,
                        enabled: _isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Perhiasan',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                      TextFormField(
                        controller: _stoneTypeController,
                        enabled: _isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Batu',
                        ),
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
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () async {
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
                                  )
                                  : const Icon(Icons.calendar_today),
                        ),
                        onTap:
                            !_isEditing
                                ? null
                                : () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _readyDate ?? DateTime.now(),
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
                      if (_isEditing)
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
                      // Tambahan: Tampilkan tombol Selesaikan Pesanan jika statusnya waiting_sales_completion
                      if (!_isEditing && _order.workflowStatus == OrderWorkflowStatus.waiting_sales_completion)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _selesaikanPesanan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Selesaikan Pesanan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}