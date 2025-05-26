import 'dart:io';

import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DesignerDetailScreen extends StatefulWidget {
  final Order order;
  const DesignerDetailScreen({super.key, required this.order});

  @override
  State<DesignerDetailScreen> createState() => _DesignerDetailScreenState();
}

class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
  late Order _order;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _acceptOrder() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(workflowStatus: OrderWorkflowStatus.designing);
    await OrderService().updateOrder(updatedOrder);
    setState(() {
      _order = updatedOrder;
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan diterima!')));
  }

  Future<void> _markDesignDone() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(workflowStatus: OrderWorkflowStatus.waiting_casting);
    await OrderService().updateOrder(updatedOrder);
    setState(() {
      _order = updatedOrder;
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Desain selesai, lanjut ke cor!')));
  }

  String showField(String? value) => (value == null || value.trim().isEmpty) ? 'Belum diisi' : value;
  String showDouble(double? value) => value == null ? 'Belum diisi' : value.toString();
  String showDate(DateTime? date) =>
      date == null ? 'Belum diisi' : "${date.day}/${date.month}/${date.year}";

  Widget _buildDisplayField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  bool get isWaiting => _order.workflowStatus == OrderWorkflowStatus.pending;
  bool get isWorking => _order.workflowStatus == OrderWorkflowStatus.designing;
  bool get isOnProgress =>
    !isWaiting && !isWorking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar referensi
            if (_order.imagePaths != null && _order.imagePaths!.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _order.imagePaths!.length,
                  itemBuilder: (context, idx) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_order.imagePaths![idx]),
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
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            _buildDisplayField('Nama Pelanggan', showField(_order.customerName)),
            _buildDisplayField('Nomor Telepon', showField(_order.customerContact)),
            _buildDisplayField('Alamat', showField(_order.address)),
            _buildDisplayField('Jenis Perhiasan', showField(_order.jewelryType)),
            _buildDisplayField('Warna Emas', showField(_order.goldColor)),
            _buildDisplayField('Jenis Emas', showField(_order.goldType)),
            _buildDisplayField('Jenis Batu', showField(_order.stoneType)),
            _buildDisplayField('Ukuran Batu', showField(_order.stoneSize)),
            _buildDisplayField('Ukuran Cincin', showField(_order.ringSize)),
            _buildDisplayField('Harga Emas/Gram', showDouble(_order.goldPricePerGram)),
            _buildDisplayField('Catatan Tambahan', showField(_order.notes)),
            _buildDisplayField('Tanggal Siap', showDate(_order.readyDate)),
            _buildDisplayField('Status', _order.workflowStatus.label),
            _buildDisplayField('Designer', showField(_order.assignedDesigner)),
            _buildDisplayField('Caster', showField(_order.assignedCaster)),
            _buildDisplayField('Carver', showField(_order.assignedCarver)),
            _buildDisplayField('Diamond Setter', showField(_order.assignedDiamondSetter)),
            _buildDisplayField('Finisher', showField(_order.assignedFinisher)),
            _buildDisplayField('Inventory', showField(_order.assignedInventory)),
            const SizedBox(height: 24),
            if (isWaiting)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _acceptOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Terima Pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (isWorking)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _markDesignDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Selesai Desain, Lanjut ke Cor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            // Jika On Progress, TIDAK ada tombol aksi apapun
          ],
        ),
      ),
    );
  }
}