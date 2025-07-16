import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class CorDetailScreen extends StatefulWidget {
  final Order order;
  const CorDetailScreen({super.key, required this.order});

  @override
  State<CorDetailScreen> createState() => _CorDetailScreenState();
}

class _CorDetailScreenState extends State<CorDetailScreen> {
  // Inisialisasi dengan order kosong agar tidak LateInitializationError
  Order _order = Order(
    ordersId: '',
    ordersCustomerName: '',
    ordersCustomerContact: '',
    ordersAddress: '',
    ordersJewelryType: '',
    ordersCreatedAt: DateTime.now(),
    ordersGoldType: '',
    ordersGoldColor: '',
    ordersRingSize: '',
    ordersFinalPrice: 0,
    ordersGoldPricePerGram: 0,
    ordersDp: 0,
    ordersImagePaths: const [],
    ordersNote: '',
    ordersWorkflowStatus: OrderWorkflowStatus.waitingCasting,
    ordersCastingWorkChecklist: const [],
  );
  List<String> _casterChecklist = [];
  bool _isProcessing = false;
  bool _isLoading = true;

  final List<String> _casterTasks = ['Casting', 'Pengecoran', 'Kasih ke Admin'];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _casterChecklist = List<String>.from(_order.ordersCastingWorkChecklist);
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final refreshedOrder = await OrderService().getOrderById(
        widget.order.ordersId,
      );
      setState(() {
        _order = refreshedOrder;
        _casterChecklist = List<String>.from(_order.ordersCastingWorkChecklist);
      });
    } catch (e) {
      setState(() {
        _order = widget.order;
        _casterChecklist = List<String>.from(_order.ordersCastingWorkChecklist);
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
        ordersCastingWorkChecklist: _casterChecklist,
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
    final isWorking =
        _order.ordersWorkflowStatus == OrderWorkflowStatus.casting;

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
                      'Nama: ${_order.ordersCustomerName}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Kontak: ${_order.ordersCustomerContact}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Alamat: ${_order.ordersAddress}',
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
                      'Jenis Perhiasan: ${_order.ordersJewelryType}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Jenis Emas: ${_order.ordersGoldType}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Warna Emas: ${_order.ordersGoldColor}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Ukuran Cincin: ${_order.ordersRingSize}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    // Batu: gunakan inventoryStoneUsed jika ada
                    if (_order.inventoryStoneUsed != null &&
                        _order.inventoryStoneUsed!.isNotEmpty) ...[
                      Text(
                        'Tipe Batu: ${_order.inventoryStoneUsed![0]['type'] ?? '-'}',
                        style: const TextStyle(color: Color(0xFF7C5E2C)),
                      ),
                      Text(
                        'Ukuran Batu: ${_order.inventoryStoneUsed![0]['size'] ?? '-'}',
                        style: const TextStyle(color: Color(0xFF7C5E2C)),
                      ),
                    ] else ...[
                      Text(
                        'Tipe Batu: -',
                        style: const TextStyle(color: Color(0xFF7C5E2C)),
                      ),
                      Text(
                        'Ukuran Batu: -',
                        style: const TextStyle(color: Color(0xFF7C5E2C)),
                      ),
                    ],
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
                      'Harga Perkiraan: Rp ${_order.ordersFinalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Harga Emas per Gram: Rp ${_order.ordersGoldPricePerGram.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'DP: Rp ${_order.ordersDp.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Sisa Lunas: Rp ${(_order.ordersFinalPrice - _order.ordersDp).clamp(0, double.infinity).toStringAsFixed(0)}',
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
                      'Tanggal Order: ${_order.ordersCreatedAt.day}/${_order.ordersCreatedAt.month}/${_order.ordersCreatedAt.year}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Tanggal Ambil: ${_order.ordersPickupDate != null ? "${_order.ordersPickupDate!.day}/${_order.ordersPickupDate!.month}/${_order.ordersPickupDate!.year}" : "-"}',
                      style: const TextStyle(color: Color(0xFF7C5E2C)),
                    ),
                    Text(
                      'Tanggal Jadi: ${_order.ordersReadyDate != null ? "${_order.ordersReadyDate!.day}/${_order.ordersReadyDate!.month}/${_order.ordersReadyDate!.year}" : "-"}',
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
                    if (_order.ordersImagePaths.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _order.ordersImagePaths.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final url = _order.ordersImagePaths[idx];
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
                        _order.ordersNote,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Status
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${_order.ordersWorkflowStatus.label}',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),

                    // Checklist hanya untuk caster
                    if (isWorking) ...[
                      const Divider(),
                      const Text(
                        'Tugas Caster',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ..._casterTasks.map(
                        (task) => CheckboxListTile(
                          value: _casterChecklist.contains(task),
                          title: Text(task),
                          onChanged:
                              _isProcessing
                                  ? null
                                  : (val) {
                                    setState(() {
                                      if (val == true) {
                                        if (!_casterChecklist.contains(task)) {
                                          _casterChecklist.add(task);
                                        }
                                      } else {
                                        _casterChecklist.remove(task);
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
                                    !_casterTasks.every(
                                      (task) => _order
                                          .ordersCastingWorkChecklist
                                          .contains(task),
                                    ))
                                ? null
                                : () async {
                                  setState(() => _isProcessing = true);
                                  try {
                                    final updatedOrder = _order.copyWith(
                                      ordersWorkflowStatus:
                                          OrderWorkflowStatus.waitingCarving,
                                    );
                                    await OrderService().updateOrder(
                                      updatedOrder,
                                    );
                                    await _fetchOrderDetail();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Order berhasil disubmit ke Carving',
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
                        child: const Text('Submit ke Carving'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tombol Terima Pesanan
                    if (_order.ordersWorkflowStatus ==
                        OrderWorkflowStatus.waitingCasting) ...[
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
                                      ordersWorkflowStatus:
                                          OrderWorkflowStatus.casting,
                                    );
                                    await OrderService().updateOrder(
                                      updatedOrder,
                                    );
                                    await _fetchOrderDetail();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Pesanan diterima, status menjadi Casting',
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
