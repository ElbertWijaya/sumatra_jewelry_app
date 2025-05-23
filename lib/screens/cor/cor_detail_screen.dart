import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'cor_task_screen.dart';

class CorDetailScreen extends StatefulWidget {
  final Order order;
  const CorDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<CorDetailScreen> createState() => _CorDetailScreenState();
}

class _CorDetailScreenState extends State<CorDetailScreen> {
  late Order _order;
  bool _isSaving = false;
  bool _lilinDone = false;
  bool _corDone = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    // TODO: Jika status checklist disimpan di order, load dari sana
  }

  Future<void> _mulaiCor() async {
    setState(() => _isSaving = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.casting,
    );
    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan masuk proses Cor!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update pesanan: $e')));
    }
    setState(() => _isSaving = false);
  }

  Future<void> _teruskanKeCarver() async {
    setState(() => _isSaving = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.waiting_carving,
    );
    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pesanan diteruskan ke Carver!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Gagal update pesanan: $e')));
    }
    setState(() => _isSaving = false);
  }

  void _onTaskChanged(bool lilin, bool cor) {
    setState(() {
      _lilinDone = lilin;
      _corDone = cor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageList = List<String>.from(_order.imagePaths ?? []);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan - Cor')),
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
                  if (_order.workflowStatus == OrderWorkflowStatus.waiting_casting)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _mulaiCor,
                        child: const Text('Mulai Cor'),
                      ),
                    ),
                  if (_order.workflowStatus == OrderWorkflowStatus.casting)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Checklist Tugas Sebelum Diteruskan:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        CorTaskScreen(
                          lilinDone: _lilinDone,
                          corDone: _corDone,
                          onChanged: _onTaskChanged,
                          enabled: !_isSaving,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_lilinDone && _corDone && !_isSaving)
                                ? _teruskanKeCarver
                                : null,
                            child: const Text('Teruskan ke Carver'),
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