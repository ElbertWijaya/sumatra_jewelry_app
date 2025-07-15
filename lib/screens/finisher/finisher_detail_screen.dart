import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class FinisherDetailScreen extends StatefulWidget {
  final Order order;
  const FinisherDetailScreen({super.key, required this.order});

  @override
  State<FinisherDetailScreen> createState() => _FinisherDetailScreenState();
}

class _FinisherDetailScreenState extends State<FinisherDetailScreen> {
  // Inisialisasi dengan order kosong agar tidak LateInitializationError
  Order _order = Order(
    id: '',
    customerName: '',
    customerContact: '',
    address: '',
    jewelryType: '',
    createdAt: DateTime.now(),
  );
  List<String> _finisherChecklist = [];
  bool _isProcessing = false;
  bool _isLoading = true;

  final List<String> _finisherTasks = ['Finishing', 'Kasih ke Admin'];

  @override
  void initState() {
    super.initState();
    // _order langsung ambil dari widget.order sebagai default
    _order = widget.order;
    _finisherChecklist = List<String>.from(_order.finishingWorkChecklist);
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Selalu fetch order terbaru dari backend (bukan dari dashboard)
      final refreshedOrder = await OrderService().getOrderById(widget.order.id);
      setState(() {
        _order = refreshedOrder;
        _finisherChecklist = List<String>.from(_order.finishingWorkChecklist);
      });
    } catch (e) {
      // Fallback tetap pakai data dari dashboard jika fetch error
      setState(() {
        _order = widget.order;
        _finisherChecklist = List<String>.from(_order.finishingWorkChecklist);
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
        finishingWorkChecklist: _finisherChecklist,
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

  @override
  Widget build(BuildContext context) {
    final isWorking = _order.workflowStatus == OrderWorkflowStatus.finishing;

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
                child: ListView(
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
                      'Nama: ${_order.customerName}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Kontak: ${_order.customerContact}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Alamat: ${_order.address}',
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
                      'Jenis Perhiasan: ${_order.jewelryType}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Jenis Emas: ${_order.goldType}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Warna Emas: ${_order.goldColor}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Ukuran Cincin: ${_order.ringSize}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Tipe Batu: ${_order.stoneType}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Ukuran Batu: ${_order.stoneSize}',
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
                      'Harga Perkiraan: Rp ${_order.finalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Harga Emas per Gram: Rp ${_order.goldPricePerGram.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'DP: Rp ${_order.dp.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Sisa Lunas: Rp ${(_order.finalPrice - _order.dp).clamp(0, double.infinity).toStringAsFixed(0)}',
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
                      'Tanggal Order: ${_order.createdAt.day}/${_order.createdAt.month}/${_order.createdAt.year}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Tanggal Ambil: ${_order.pickupDate != null ? "${_order.pickupDate!.day}/${_order.pickupDate!.month}/${_order.pickupDate!.year}" : "-"}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Tanggal Jadi: ${_order.readyDate != null ? "${_order.readyDate!.day}/${_order.readyDate!.month}/${_order.readyDate!.year}" : "-"}',
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
                    if (_order.imagePaths.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _order.imagePaths.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final url = _order.imagePaths[idx];
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => Dialog(
                                        child: InteractiveViewer(
                                          child: Image.network(
                                            url,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  url,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (c, e, s) =>
                                          const Icon(Icons.broken_image),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      const Text('Tidak ada gambar referensi.'),
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
                        _order.notes,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Status
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${_order.workflowStatus.label}',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),

                    // Checklist hanya untuk finisher
                    if (isWorking) ...[
                      const Divider(),
                      const Text(
                        'Tugas Finisher',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ..._finisherTasks.map(
                        (task) => CheckboxListTile(
                          value: _finisherChecklist.contains(task),
                          title: Text(task),
                          onChanged:
                              _isProcessing
                                  ? null
                                  : (val) {
                                    setState(() {
                                      if (val == true) {
                                        if (!_finisherChecklist.contains(
                                          task,
                                        )) {
                                          _finisherChecklist.add(task);
                                        }
                                      } else {
                                        _finisherChecklist.remove(task);
                                      }
                                    });
                                  },
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _updateChecklist,
                        child:
                            _isProcessing
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Update Checklist'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed:
                            (_isProcessing ||
                                    !_finisherTasks.every(
                                      (task) => _order.finishingWorkChecklist
                                          .contains(task),
                                    ))
                                ? null
                                : () async {
                                  setState(() => _isProcessing = true);
                                  try {
                                    final updatedOrder = _order.copyWith(
                                      workflowStatus:
                                          OrderWorkflowStatus.waitingInventory,
                                    );
                                    await OrderService().updateOrder(
                                      updatedOrder,
                                    );
                                    await _fetchOrderDetail();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Order berhasil disubmit ke Inventory',
                                        ),
                                      ),
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
                        child: const Text('Submit ke Inventory'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tombol Terima Pesanan
                    if (_order.workflowStatus ==
                        OrderWorkflowStatus.waitingFinishing) ...[
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
                                    final updatedOrder = _order.copyWith(
                                      workflowStatus:
                                          OrderWorkflowStatus.finishing,
                                    );
                                    await OrderService().updateOrder(
                                      updatedOrder,
                                    );
                                    await _fetchOrderDetail();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Pesanan diterima, status menjadi Finishing',
                                        ),
                                      ),
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
