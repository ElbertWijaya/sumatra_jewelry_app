import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DiamondSetterDetailScreen extends StatefulWidget {
  final Order order;
  final String fromTab; // 'waiting', 'working', 'onprogress'
  final List<String> diamondSetterTasks;
  const DiamondSetterDetailScreen({
    super.key,
    required this.order,
    required this.fromTab,
    required this.diamondSetterTasks,
  });

  @override
  State<DiamondSetterDetailScreen> createState() =>
      _DiamondSetterDetailScreenState();
}

class _DiamondSetterDetailScreenState extends State<DiamondSetterDetailScreen> {
  late Order _order;
  List<String> _diamondSetterChecklist = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _diamondSetterChecklist = List<String>.from(
      _order.ordersDiamondSettingWorkChecklist,
    );
    // Fetch latest data dari database ketika screen dibuka
    _refreshOrderData();
  }

  Future<void> _refreshOrderData() async {
    try {
      final refreshedOrder = await OrderService().getOrderById(_order.ordersId);
      setState(() {
        _order = refreshedOrder;
        _diamondSetterChecklist = List<String>.from(
          refreshedOrder.ordersDiamondSettingWorkChecklist,
        );
      });
    } catch (e) {
      // Jika gagal fetch, tetap gunakan data yang ada
      print('Failed to refresh order data: $e');
    }
  }

  Future<void> _startDiamondSetting() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        ordersWorkflowStatus: OrderWorkflowStatus.stoneSetting,
      );
      await OrderService().updateOrder(updatedOrder);
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan masuk tahap Stone Setting')),
      );
      Navigator.of(context).pop(true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        ordersDiamondSettingWorkChecklist: _diamondSetterChecklist,
      );
      await OrderService().updateOrder(updatedOrder);
      setState(() {
        _order = updatedOrder;
        _diamondSetterChecklist = List<String>.from(
          updatedOrder.ordersDiamondSettingWorkChecklist,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist berhasil diupdate')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _submitToFinishing() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        ordersWorkflowStatus: OrderWorkflowStatus.waitingFinishing,
      );
      await OrderService().updateOrder(updatedOrder);
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan dikirim ke Finishing!')),
      );
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
                      : 'http://192.168.110.147/sumatra_api/orders_photo/$img';
              return Container(
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
                'Harga Perkiraan: Rp ${_order.ordersFinalPrice != null ? _order.ordersFinalPrice!.toStringAsFixed(0) : '-'}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harga Akhir: Rp ${_order.ordersFinalPrice != null ? _order.ordersFinalPrice!.toStringAsFixed(0) : '-'}',
                  ),
                  Text(
                    'DP: Rp ${_order.ordersDp != null ? _order.ordersDp!.toStringAsFixed(0) : '-'}',
                  ),
                  Text(
                    'Sisa Lunas: Rp ${_order.ordersFinalPrice != null && _order.ordersDp != null ? (_order.ordersFinalPrice! - _order.ordersDp!).toStringAsFixed(0) : '-'}',
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
                    'Diamond Setter',
                    widget.diamondSetterTasks,
                    _order.ordersDiamondSettingWorkChecklist,
                    Icons.diamond,
                    Colors.purple,
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
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Mulai Stone Setting',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: _isProcessing ? null : _startDiamondSetting,
                  ),
                ),
              ),
            if (widget.fromTab == 'working')
              Column(
                children: [
                  ...widget.diamondSetterTasks.map(
                    (task) => CheckboxListTile(
                      value: _diamondSetterChecklist.contains(task),
                      title: Text(task),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _diamondSetterChecklist.add(task);
                          } else {
                            _diamondSetterChecklist.remove(task);
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
                  if (_diamondSetterChecklist.length ==
                          widget.diamondSetterTasks.length &&
                      _diamondSetterChecklist.toSet().containsAll(
                        widget.diamondSetterTasks.toSet(),
                      ) &&
                      _order.ordersDiamondSettingWorkChecklist.length ==
                          widget.diamondSetterTasks.length &&
                      _order.ordersDiamondSettingWorkChecklist
                          .toSet()
                          .containsAll(widget.diamondSetterTasks.toSet()))
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
                          'Submit ke Finishing',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed: _isProcessing ? null : _submitToFinishing,
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
