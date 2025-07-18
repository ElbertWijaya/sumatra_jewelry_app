import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DesignerDetailScreen extends StatefulWidget {
  final Order order;
  final String fromTab; // 'waiting', 'working', 'onprogress'
  const DesignerDetailScreen({
    super.key,
    required this.order,
    required this.fromTab,
  });

  @override
  State<DesignerDetailScreen> createState() => _DesignerDetailScreenState();
}

class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
  String formatRupiah(num? value) {
    if (value == null || value == 0) return '-';
    return 'Rp ' +
        value
            .toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            );
  }

  final List<String> designerTasks = ['Designing', '3D Printing', 'Pengecekan'];
  late Order _order;
  List<String> _designerChecklist = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _designerChecklist = List<String>.from(_order.ordersDesignerWorkChecklist);
  }

  Future<void> _startDesigning() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        ordersWorkflowStatus: OrderWorkflowStatus.designing,
      );
      final result = await OrderService().updateOrder(updatedOrder);
      if (result == true) {
        setState(() {
          _order = updatedOrder;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan masuk tahap Designing')),
        );
        // Refresh layar
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update status pesanan!'),
          ), // tampilkan pesan default
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        ordersDesignerWorkChecklist: _designerChecklist,
      );
      await OrderService().updateOrder(updatedOrder);
      setState(() {
        _order = updatedOrder;
        _designerChecklist = List<String>.from(
          updatedOrder.ordersDesignerWorkChecklist,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist berhasil diupdate')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _submitToCor() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        ordersWorkflowStatus: OrderWorkflowStatus.waitingCasting,
      );
      await OrderService().updateOrder(updatedOrder);
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pesanan dikirim ke Cor!')));
      Navigator.of(context).pop(true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildChecklist(
    String title,
    List<String> defaultTasks,
    List<String>? checkedTasks,
    IconData icon,
    Color color,
  ) {
    final checked = checkedTasks ?? [];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...defaultTasks.map((task) {
              final isChecked = checked.contains(task);
              return Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isChecked ? color : Colors.grey[300],
                      border: Border.all(color: color, width: 2),
                    ),
                    child:
                        isChecked
                            ? Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                  ),
                  Text(task, style: TextStyle(fontSize: 15)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStoneInfo() {
    final stoneList = _order.ordersStoneUsed;
    if (stoneList.isEmpty) {
      return Card(
        color: const Color(0xFFFFF8E1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Tidak ada informasi batu'),
        ),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            stoneList.map((stone) {
              return Card(
                margin: const EdgeInsets.only(right: 10),
                color: const Color(0xFFFFF8E1),
                child: Container(
                  width: 110,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bentuk: ${stone['shape'] ?? '-'}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Jumlah: ${stone['count'] ?? '-'} pcs'),
                      Text('Ukuran: ${stone['carat'] ?? '-'} ct'),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_order.ordersImagePaths.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber),
          color: Colors.amber[50],
        ),
        child: const Text('-'),
      );
    }
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            _order.ordersImagePaths.map((img) {
              final String imageUrl =
                  img.startsWith('http')
                      ? img
                      : 'http://192.168.83.117/sumatra_api/orders_photo/$img';
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => Dialog(
                          backgroundColor: Colors.black,
                          insetPadding: const EdgeInsets.all(0),
                          child: Stack(
                            children: [
                              InteractiveViewer(
                                panEnabled: true,
                                minScale: 1,
                                maxScale: 5,
                                child: Center(
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 24,
                                right: 24,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ...existing info widgets...
            // Informasi Pelanggan
            Text(
              'Informasi Pelanggan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            ListTile(
              leading: Icon(Icons.person, color: Colors.amber),
              title: Text(_order.ordersCustomerName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Telepon: ${_order.ordersCustomerContact}'),
                  Text('Alamat: ${_order.ordersAddress}'),
                ],
              ),
            ),
            const Divider(),
            // Informasi Barang
            Text(
              'Informasi Barang',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.amber),
              title: Text(_order.ordersJewelryType),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jenis Emas: ${_order.ordersGoldType}'),
                  Text('Warna Emas: ${_order.ordersGoldColor}'),
                ],
              ),
            ),
            const Divider(),
            // Informasi Batu (Card)
            Text(
              'Informasi Batu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            Card(
              elevation: 2,
              color: const Color(0xFFFFF8E1),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildStoneInfo()],
                ),
              ),
            ),
            const Divider(),
            // Informasi Tanggal
            Text(
              'Informasi Tanggal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            ListTile(
              leading: Icon(Icons.date_range, color: Colors.amber),
              title: Text(
                'Tanggal Siap: ${_order.ordersReadyDate != null ? "${_order.ordersReadyDate!.day.toString().padLeft(2, '0')}/${_order.ordersReadyDate!.month.toString().padLeft(2, '0')}/${_order.ordersReadyDate!.year} ${_order.ordersReadyDate!.hour.toString().padLeft(2, '0')}:${_order.ordersReadyDate!.minute.toString().padLeft(2, '0')}:${_order.ordersReadyDate!.second.toString().padLeft(2, '0')}" : "-"}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Pickup: ${_order.ordersPickupDate != null ? "${_order.ordersPickupDate!.day.toString().padLeft(2, '0')}/${_order.ordersPickupDate!.month.toString().padLeft(2, '0')}/${_order.ordersPickupDate!.year} ${_order.ordersPickupDate!.hour.toString().padLeft(2, '0')}:${_order.ordersPickupDate!.minute.toString().padLeft(2, '0')}:${_order.ordersPickupDate!.second.toString().padLeft(2, '0')}" : "-"}',
                  ),
                  Text(
                    'Tanggal Dibuat: ${_order.ordersCreatedAt.day.toString().padLeft(2, '0')}/${_order.ordersCreatedAt.month.toString().padLeft(2, '0')}/${_order.ordersCreatedAt.year} ${_order.ordersCreatedAt.hour.toString().padLeft(2, '0')}:${_order.ordersCreatedAt.minute.toString().padLeft(2, '0')}:${_order.ordersCreatedAt.second.toString().padLeft(2, '0')}',
                  ),
                  Text(
                    'Terakhir Update: ${_order.ordersUpdatedAt != null ? "${_order.ordersUpdatedAt!.day.toString().padLeft(2, '0')}/${_order.ordersUpdatedAt!.month.toString().padLeft(2, '0')}/${_order.ordersUpdatedAt!.year} ${_order.ordersUpdatedAt!.hour.toString().padLeft(2, '0')}:${_order.ordersUpdatedAt!.minute.toString().padLeft(2, '0')}:${_order.ordersUpdatedAt!.second.toString().padLeft(2, '0')}" : "-"}',
                  ),
                ],
              ),
            ),
            const Divider(),
            // Informasi Harga
            Text(
              'Informasi Harga',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.amber),
              title: Text(
                'Harga Perkiraan: ${formatRupiah(_order.ordersFinalPrice)}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Harga Akhir: ${formatRupiah(_order.ordersFinalPrice)}'),
                  Text('DP: ${formatRupiah(_order.ordersDp)}'),
                  Text(
                    'Sisa Lunas: ${_order.ordersFinalPrice != null && _order.ordersDp != null ? formatRupiah(_order.ordersFinalPrice! - _order.ordersDp!) : '-'}',
                  ),
                ],
              ),
            ),
            const Divider(),
            // Gambar Referensi
            Text(
              'Gambar Referensi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            _buildImageGallery(),
            const Divider(),
            // Checklist Pekerja
            Text(
              'Checklist Pekerja',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChecklist(
                    'Designer',
                    designerTasks,
                    _order.ordersDesignerWorkChecklist,
                    Icons.design_services,
                    Colors.blue,
                  ),
                  // ...existing code for other roles...
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Bagian bawah sesuai tab
            if (widget.fromTab == 'waiting')
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Mulai Design',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: _isProcessing ? null : _startDesigning,
                  ),
                ),
              ),
            if (widget.fromTab == 'working')
              Column(
                children: [
                  ...designerTasks.map(
                    (task) => CheckboxListTile(
                      value: _designerChecklist.contains(task),
                      title: Text(task),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _designerChecklist.add(task);
                          } else {
                            _designerChecklist.remove(task);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _updateChecklist,
                    child:
                        _isProcessing
                            ? const CircularProgressIndicator()
                            : const Text('Update Progress'),
                  ),
                  const SizedBox(height: 12),
                  if (_designerChecklist.length == designerTasks.length &&
                      _designerChecklist.toSet().containsAll(
                        designerTasks.toSet(),
                      ) &&
                      _order.ordersDesignerWorkChecklist.length ==
                          designerTasks.length &&
                      _order.ordersDesignerWorkChecklist.toSet().containsAll(
                        designerTasks.toSet(),
                      ))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.send),
                        label: const Text(
                          'Submit ke Cor',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed: _isProcessing ? null : _submitToCor,
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
