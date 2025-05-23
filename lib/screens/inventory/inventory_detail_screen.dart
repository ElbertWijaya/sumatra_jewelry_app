import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'inventory_task_screen.dart.dart';

class InventoryDetailScreen extends StatefulWidget {
  final Order order;
  const InventoryDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  late Order _order;
  bool _isSaving = false;

  // Inventory input fields
  final TextEditingController _kodeBarangController = TextEditingController();
  final TextEditingController _lokasiRakController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    // TODO: Load inventory data from order if available
  }

  @override
  void dispose() {
    _kodeBarangController.dispose();
    _lokasiRakController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _mulaiInventory() async {
    setState(() => _isSaving = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.inventory,
    );
    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan masuk proses Inventory!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal update pesanan: $e')));
    }
    setState(() => _isSaving = false);
  }

  Future<void> _submitKeSales() async {
    setState(() => _isSaving = true);
    // TODO: Simpan data inventory ke order jika sudah tersedia di backend/service
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.waiting_sales_completion,
      // contoh: additionalData: {...}
    );
    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pesanan diteruskan ke Sales!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal update pesanan: $e')));
    }
    setState(() => _isSaving = false);
  }

  bool get _isFormValid =>
      _kodeBarangController.text.trim().isNotEmpty &&
      _lokasiRakController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final imageList = List<String>.from(_order.imagePaths ?? []);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan - Inventory')),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Referensi Gambar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageList.length,
                      itemBuilder: (context, idx) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(imageList[idx]),
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Nama Pelanggan: ${_order.customerName}'),
                  Text('Nomor Telepon: ${_order.customerContact}'),
                  Text('Alamat: ${_order.address}'),
                  Text('Jenis Perhiasan: ${_order.jewelryType}'),
                  if (_order.stoneType != null && _order.stoneType!.isNotEmpty)
                    Text('Jenis Batu: ${_order.stoneType}'),
                  if (_order.stoneSize != null && _order.stoneSize!.isNotEmpty)
                    Text('Ukuran Batu: ${_order.stoneSize}'),
                  if (_order.ringSize != null && _order.ringSize!.isNotEmpty)
                    Text('Ukuran Cincin: ${_order.ringSize}'),
                  if (_order.goldPricePerGram != null)
                    Text('Harga Emas/Gram: ${_order.goldPricePerGram}'),
                  if (_order.notes != null && _order.notes!.isNotEmpty)
                    Text('Catatan Tambahan: ${_order.notes}'),
                  if (_order.readyDate != null)
                    Text(
                      'Tanggal Siap: ${_order.readyDate!.day}/${_order.readyDate!.month}/${_order.readyDate!.year}',
                    ),
                  const SizedBox(height: 24),
                  if (_order.workflowStatus == OrderWorkflowStatus.waiting_inventory)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _mulaiInventory,
                        child: const Text('Mulai Input Inventory'),
                      ),
                    ),
                  if (_order.workflowStatus == OrderWorkflowStatus.inventory)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data Inventory',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        InventoryTaskScreen(
                          kodeBarangController: _kodeBarangController,
                          lokasiRakController: _lokasiRakController,
                          catatanController: _catatanController,
                          enabled: !_isSaving,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isFormValid && !_isSaving ? _submitKeSales : null,
                            child: const Text('Submit ke Sales'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}