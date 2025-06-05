import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DiamondSetterDetailScreen extends StatefulWidget {
  final String orderId;
  const DiamondSetterDetailScreen({super.key, required this.orderId});

  @override
  State<DiamondSetterDetailScreen> createState() => _DiamondSetterDetailScreenState();
}

class _DiamondSetterDetailScreenState extends State<DiamondSetterDetailScreen> {
  Order? _order;
  bool _isLoading = true;
  List<String> _checked = [];
  final List<String> _tasks = ['Pasang Batu', 'Pengecekan', 'Serah ke Finisher'];

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    final order = await OrderService().getOrderById(widget.orderId);
    setState(() {
      _order = order;
      _checked = List<String>.from(order.diamondSettingWorkChecklist ?? []);
      _isLoading = false;
    });
  }

  Future<void> _updateChecklist(String task, bool checked) async {
    setState(() {
      if (checked) {
        if (!_checked.contains(task)) _checked.add(task);
      } else {
        _checked.remove(task);
      }
    });
    await OrderService().updateOrder(
      _order!.copyWith(diamondSettingWorkChecklist: _checked),
    );
  }

  Future<void> _startStoneSetting() async {
    final success = await OrderService().updateOrder(
      _order!.copyWith(workflowStatus: OrderWorkflowStatus.stoneSetting),
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan masuk tahap Stone Setting!')),
      );
      await _fetchOrder();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memulai stone setting!')),
      );
    }
  }

  Future<void> _submitToFinisher() async {
    final success = await OrderService().updateOrder(
      _order!.copyWith(
        workflowStatus: OrderWorkflowStatus.waitingFinishing,
        diamondSettingWorkChecklist: _checked,
      ),
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dikirim ke Finisher!')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal submit!')),
      );
    }
  }

  Widget _buildChecklist(String title, List<String>? checklist) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _order == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isWaitingDiamondSetting = _order?.workflowStatus == OrderWorkflowStatus.waitingDiamondSetting;
    final isStoneSetting = _order?.workflowStatus == OrderWorkflowStatus.stoneSetting;
    final allChecked = _tasks.every((task) => _checked.contains(task));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan Diamond Setter'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // --- Informasi Pesanan ---
            const Text('Informasi Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
            const Divider(),
            Text('Nama: ${_order!.customerName}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Kontak: ${_order!.customerContact}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Alamat: ${_order!.address}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            const SizedBox(height: 12),
            const Text('Informasi Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
            const Divider(),
            Text('Jenis Perhiasan: ${_order!.jewelryType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Jenis Emas: ${_order!.goldType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Warna Emas: ${_order!.goldColor}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Ukuran Cincin: ${_order!.ringSize}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Tipe Batu: ${_order!.stoneType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Ukuran Batu: ${_order!.stoneSize}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            const SizedBox(height: 12),
            const Text('Informasi Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
            const Divider(),
            Text('Harga Perkiraan: Rp ${_order!.finalPrice.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Harga Emas per Gram: Rp ${_order!.goldPricePerGram.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('DP: Rp ${_order!.dp.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Sisa Lunas: Rp ${(_order!.finalPrice - _order!.dp).clamp(0, double.infinity).toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 12),
            const Text('Informasi Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
            const Divider(),
            Text('Tanggal Order: ${_order!.createdAt.day}/${_order!.createdAt.month}/${_order!.createdAt.year}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Tanggal Ambil: ${_order!.pickupDate != null ? "${_order!.pickupDate!.day}/${_order!.pickupDate!.month}/${_order!.pickupDate!.year}" : "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Tanggal Jadi: ${_order!.readyDate != null ? "${_order!.readyDate!.day}/${_order!.readyDate!.month}/${_order!.readyDate!.year}" : "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            const SizedBox(height: 12),
            const Text('Referensi Gambar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._order!.imagePaths.map((img) => Container(
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
              child: Text(_order!.notes, style: const TextStyle(fontFamily: 'Courier', fontSize: 14)),
            ),
            const SizedBox(height: 8),
            Text('Status: ${_order!.workflowStatus.label}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            const Divider(),

            // Checklist lain (readonly)
            _buildChecklist('Checklist Designer', _order!.designerWorkChecklist),
            _buildChecklist('Checklist Casting', _order!.castingWorkChecklist),
            _buildChecklist('Checklist Carving', _order!.carvingWorkChecklist),
            _buildChecklist('Checklist Diamond Setting', _order!.diamondSettingWorkChecklist),
            _buildChecklist('Checklist Finishing', _order!.finishingWorkChecklist),
            _buildChecklist('Checklist Inventory', _order!.inventoryWorkChecklist),

            const SizedBox(height: 24),

            // --- Workflow Button & Checklist ---
            if (isWaitingDiamondSetting)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mulai Pasang Batu!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _startStoneSetting,
              ),

            if (isStoneSetting) ...[
              const Text('Checklist Tugas Diamond Setter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              ..._tasks.map((task) => CheckboxListTile(
                    value: _checked.contains(task),
                    title: Text(task),
                    onChanged: (val) {
                      _updateChecklist(task, val ?? false);
                    },
                  )),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Submit ke Finisher'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: allChecked ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: allChecked ? _submitToFinisher : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Checklist sudah sesuai designer
// Tab sudah sesuai designer