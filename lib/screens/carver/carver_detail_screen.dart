import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class CarverDetailScreen extends StatefulWidget {
  final Order order;
  const CarverDetailScreen({super.key, required this.order});

  @override
  State<CarverDetailScreen> createState() => _CarverDetailScreenState();
}

class _CarverDetailScreenState extends State<CarverDetailScreen> {
  // Inisialisasi dengan order kosong agar tidak LateInitializationError
  Order _order = Order(
    id: '',
    customerName: '',
    customerContact: '',
    address: '',
    jewelryType: '',
    createdAt: DateTime.now(),
  );
  List<String> _carverChecklist = [];
  bool _isProcessing = false;
  bool _isLoading = true;

  final List<String> _carverTasks = [
    'Bom', 'Polish', 'Pengecekan', 'Kasih ke Olivia',
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _carverChecklist = List<String>.from(_order.carvingWorkChecklist ?? []);
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
        _carverChecklist = List<String>.from(_order.carvingWorkChecklist ?? []);
      });
    } catch (e) {
      setState(() {
        _order = widget.order;
        _carverChecklist = List<String>.from(_order.carvingWorkChecklist ?? []);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        carvingWorkChecklist: _carverChecklist,
      );
      await OrderService().updateOrder(updatedOrder);

      // Delay agar backend update
      await Future.delayed(const Duration(milliseconds: 300));

      // Fetch order detail terbaru setelah update
      await _fetchOrderDetail();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist berhasil diupdate')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildChecklist(String title, List<String>? checklist) {
    print(_order.designerWorkChecklist);
    print(_order.designerWorkChecklist.runtimeType);

    if (checklist == null || checklist.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...checklist.map((item) => Row(
          children: [
            const Icon(Icons.check, color: Colors.green, size: 18),
            const SizedBox(width: 4),
            Text(item),
          ],
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFullChecklist(String title, List<String> allTasks, List<String>? checkedTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...allTasks.map((item) => Row(
          children: [
            Icon(
              (checkedTasks ?? []).contains(item) ? Icons.check_circle : Icons.radio_button_unchecked,
              color: (checkedTasks ?? []).contains(item) ? Colors.green : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(item),
          ],
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWorking = _order.workflowStatus == OrderWorkflowStatus.carving;

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
                  const Divider(),

                  // Checklist hanya untuk carver
                  if (isWorking) ...[
                    const Divider(),
                    const Text('Tugas Carver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ..._carverTasks.map((task) => CheckboxListTile(
                          value: _carverChecklist.contains(task),
                          title: Text(task),
                          onChanged: _isProcessing
                              ? null
                              : (val) {
                                  setState(() {
                                    if (val == true) {
                                      if (!_carverChecklist.contains(task)) {
                                        _carverChecklist.add(task);
                                      }
                                    } else {
                                      _carverChecklist.remove(task);
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
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: (_isProcessing ||
                          !_carverTasks.every((task) => _order.carvingWorkChecklist.contains(task)))
                          ? null
                          : () async {
                              setState(() => _isProcessing = true);
                              try {
                                final updatedOrder = _order.copyWith(
                                  workflowStatus: OrderWorkflowStatus.waitingDiamondSetting,
                                );
                                await OrderService().updateOrder(updatedOrder);
                                await _fetchOrderDetail();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Order berhasil disubmit ke Diamond Setting')),
                                );
                                Navigator.of(context).pop(true);
                              } finally {
                                setState(() => _isProcessing = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit ke Diamond Setting'),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tombol Terima Pesanan
                  if (_order.workflowStatus == OrderWorkflowStatus.waitingCarving) ...[
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
                                  workflowStatus: OrderWorkflowStatus.carving,
                                );
                                await OrderService().updateOrder(updatedOrder);
                                await _fetchOrderDetail();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pesanan diterima, status menjadi Carving')),
                                );
                                Navigator.of(context).pop(true);
                              } finally {
                                setState(() => _isProcessing = false);
                              }
                            },
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}