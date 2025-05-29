import 'package:flutter/material.dart';
import '../../models/order.dart';

class SalesDetailScreen extends StatelessWidget {
  final Order order;
  const SalesDetailScreen({super.key, required this.order});

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
    final isWaitingSalesCheck = order.workflowStatus == OrderWorkflowStatus.waitingSalesCheck;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Informasi Pelanggan
            const Text('Informasi Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
            const Divider(),
            Text('Nama: ${order.customerName}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Kontak: ${order.customerContact}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Alamat: ${order.address}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            const SizedBox(height: 12),

            // Informasi Barang
            const Text('Informasi Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
            const Divider(),
            Text('Jenis Perhiasan: ${order.jewelryType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Jenis Emas: ${order.goldType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Warna Emas: ${order.goldColor}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Ukuran Cincin: ${order.ringSize}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Tipe Batu: ${order.stoneType}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Ukuran Batu: ${order.stoneSize}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            const SizedBox(height: 12),

            // Informasi Harga
            const Text('Informasi Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
            const Divider(),
            Text('Harga Perkiraan: Rp ${order.finalPrice.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Harga Emas per Gram: Rp ${order.goldPricePerGram.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('DP: Rp ${order.dp.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Sisa Lunas: Rp ${(order.finalPrice - order.dp).clamp(0, double.infinity).toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 12),

            // Informasi Tanggal
            const Text('Informasi Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
            const Divider(),
            Text('Tanggal Order: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Tanggal Ambil: ${order.pickupDate != null ? "${order.pickupDate!.day}/${order.pickupDate!.month}/${order.pickupDate!.year}" : "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            Text('Tanggal Jadi: ${order.readyDate != null ? "${order.readyDate!.day}/${order.readyDate!.month}/${order.readyDate!.year}" : "-"}', style: const TextStyle(color: Color(0xFF7C5E2C))),
            const SizedBox(height: 12),

            // Gambar Referensi
            const Text('Referensi Gambar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5E2C))),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...order.imagePaths.map((img) => Container(
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
              child: Text(order.notes, style: const TextStyle(fontFamily: 'Courier', fontSize: 14)),
            ),

            // Status
            const SizedBox(height: 8),
            Text('Status: ${order.workflowStatus.label}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            const Divider(),

            // Checklist
            _buildChecklist('Checklist Designer', order.designerWorkChecklist),
            _buildChecklist('Checklist Casting', order.castingWorkChecklist),
            _buildChecklist('Checklist Carving', order.carvingWorkChecklist),
            _buildChecklist('Checklist Diamond Setting', order.diamondSettingWorkChecklist),
            _buildChecklist('Checklist Finishing', order.finishingWorkChecklist),
            _buildChecklist('Checklist Inventory', order.inventoryWorkChecklist),

            const SizedBox(height: 24),
            if (isWaitingSalesCheck) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/sales/edit',
                          arguments: order,
                        );
                        if (result == true) Navigator.pop(context, true);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Konfirmasi Hapus'),
                            content: const Text('Yakin ingin menghapus pesanan ini?'),
                            actions: [
                              TextButton(
                                child: const Text('Batal'),
                                onPressed: () => Navigator.pop(ctx, false),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Hapus'),
                                onPressed: () => Navigator.pop(ctx, true),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // TODO: Panggil service hapus pesanan dari database
                          // await OrderService().deleteOrder(order.id);
                          Navigator.pop(context, true);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C5E2C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('Submit ke Designer', style: TextStyle(fontSize: 16)),
                  onPressed: () async {
                    // TODO: Update status pesanan ke waitingDesigner di database
                    // await OrderService().updateOrderStatus(order.id, 'waiting_designer');
                    Navigator.pop(context, true);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}