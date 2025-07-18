import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SalesDetailScreen extends StatelessWidget {
  // Daftar tugas default per role
  final List<String> designerTasks = ['Designing', '3D Printing', 'Pengecekan'];
  final List<String> corTasks = ['Lilin', 'Cor', 'Kasih ke Admin'];
  final List<String> carverTasks = [
    'Cap',
    'Bom',
    'Pengecekan',
    'Kasih ke Admin',
  ];
  final List<String> diamondSetterTasks = [
    'Pilih batu',
    'Pasang batu',
    'Kasih ke Admin',
  ];
  final List<String> finisherTasks = ['Chrome', 'Kasih ke Admin'];
  final Order order;
  SalesDetailScreen({super.key, required this.order});

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
    final stoneList = order.ordersStoneUsed;
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
    if (order.ordersImagePaths.isEmpty) {
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
            order.ordersImagePaths.map((img) {
              final String imageUrl =
                  img.startsWith('http')
                      ? img
                      : 'http://192.168.83.117/sumatra_api/orders_photo/$img';
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
    String formatRupiah(num? value) {
      if (value == null || value == 0) return '-';
      final formatter = NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(value);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFD4AF37),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    tooltip: 'Edit',
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
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.red[700],
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    tooltip: 'Hapus',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Konfirmasi Hapus'),
                              content: const Text(
                                'Yakin ingin menghapus pesanan ini?',
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Batal'),
                                  onPressed: () => Navigator.pop(ctx, false),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Hapus'),
                                  onPressed: () => Navigator.pop(ctx, true),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (ctx) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        );
                        try {
                          // Panggil fungsi hapus pesanan dari backend
                          final response = await http.post(
                            Uri.parse(
                              'http://192.168.83.54/sumatra_api/delete_orders.php',
                            ),
                            body: {'orders_id': order.ordersId.toString()},
                          );
                          Navigator.pop(context); // tutup loading
                          if (response.statusCode == 200) {
                            final resp = jsonDecode(response.body);
                            if (resp['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pesanan berhasil dihapus!'),
                                ),
                              );
                              Navigator.pop(
                                context,
                                true,
                              ); // kembali ke list/dashboard
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal menghapus: ${resp['error'] ?? 'Unknown error'}',
                                  ),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal menghapus: ${response.body}',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          Navigator.pop(context); // tutup loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menghapus: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Pelanggan
            Text(
              'Informasi Pelanggan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            ListTile(
              leading: Icon(Icons.person, color: Colors.amber),
              title: Text(order.ordersCustomerName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Telepon: ${order.ordersCustomerContact}'),
                  Text('Alamat: ${order.ordersAddress}'),
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
              title: Text(order.ordersJewelryType),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jenis Emas: ${order.ordersGoldType}'),
                  Text('Warna Emas: ${order.ordersGoldColor}'),
                ],
              ),
            ),
            // Memo/Note
            if (order.ordersNote != null && order.ordersNote.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Transform.rotate(
                  angle: -0.01, // Sedikit miring seperti memo
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _DashedBorderPainter(),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.yellow[50],
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 20,
                            ),
                            child: Text(
                              order.ordersNote,
                              style: const TextStyle(
                                fontFamily:
                                    'Montserrat', // atau font tipis lain
                                fontSize: 16,
                                color: Color(0xFF6D4C00),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ),
                      // Sticky tape di pojok kiri atas
                      Positioned(
                        left: 18,
                        top: 0,
                        child: Container(
                          width: 32,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      // Sticky tape di pojok kanan bawah
                      Positioned(
                        right: 18,
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                'Tanggal Siap: ${order.ordersReadyDate != null ? "${order.ordersReadyDate!.day.toString().padLeft(2, '0')}/${order.ordersReadyDate!.month.toString().padLeft(2, '0')}/${order.ordersReadyDate!.year}" : "-"}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Pickup: ${order.ordersPickupDate != null ? "${order.ordersPickupDate!.day.toString().padLeft(2, '0')}/${order.ordersPickupDate!.month.toString().padLeft(2, '0')}/${order.ordersPickupDate!.year}" : "-"}',
                  ),
                  Text(
                    'Tanggal Dibuat: ${order.ordersCreatedAt.day.toString().padLeft(2, '0')}/${order.ordersCreatedAt.month.toString().padLeft(2, '0')}/${order.ordersCreatedAt.year} ${order.ordersCreatedAt.hour.toString().padLeft(2, '0')}:${order.ordersCreatedAt.minute.toString().padLeft(2, '0')}:${order.ordersCreatedAt.second.toString().padLeft(2, '0')}',
                  ),
                  Text(
                    'Terakhir Update: ${order.ordersUpdatedAt != null ? "${order.ordersUpdatedAt!.day.toString().padLeft(2, '0')}/${order.ordersUpdatedAt!.month.toString().padLeft(2, '0')}/${order.ordersUpdatedAt!.year} ${order.ordersUpdatedAt!.hour.toString().padLeft(2, '0')}:${order.ordersUpdatedAt!.minute.toString().padLeft(2, '0')}:${order.ordersUpdatedAt!.second.toString().padLeft(2, '0')}" : "-"}',
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
                'Harga Perkiraan: ${formatRupiah(order.ordersFinalPrice)}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harga Emas per Gram: ${formatRupiah(order.ordersGoldPricePerGram)}',
                  ),
                  Text('DP: ${formatRupiah(order.ordersDp)}'),
                  Text(
                    'Sisa Lunas: ${order.ordersFinalPrice != null && order.ordersDp != null && order.ordersFinalPrice != 0 && order.ordersDp != 0 ? formatRupiah(order.ordersFinalPrice! - order.ordersDp!) : '-'}',
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
                    order.ordersDesignerWorkChecklist,
                    Icons.design_services,
                    Colors.blue,
                  ),
                  _buildChecklist(
                    'Cor',
                    corTasks,
                    order.ordersCastingWorkChecklist,
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  _buildChecklist(
                    'Carver',
                    carverTasks,
                    order.ordersCarvingWorkChecklist,
                    Icons.handyman,
                    Colors.brown,
                  ),
                  _buildChecklist(
                    'Diamond Setter',
                    diamondSetterTasks,
                    order.ordersDiamondSettingWorkChecklist,
                    Icons.diamond,
                    Colors.purple,
                  ),
                  _buildChecklist(
                    'Finisher',
                    finisherTasks,
                    order.ordersFinishingWorkChecklist,
                    Icons.check,
                    Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
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
            icon: const Icon(Icons.send),
            label: const Text(
              'Submit ke Designer',
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () async {
              // Submit ke Designer: update workflow pesanan
              // TODO: Panggil OrderService.updateOrder dengan status waitingDesigner
              // Contoh:
              // await OrderService().updateOrder(order.copyWith(ordersWorkflowStatus: WorkflowStatus.waitingDesigner));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pesanan dikirim ke Designer!')),
              );
              // Optionally, pop context or refresh
            },
          ),
        ),
      ),
    );
  }
}

// CustomPainter untuk border putus-putus memo
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = 12.0;
    final paint =
        Paint()
          ..color = Colors.amber
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
            Radius.circular(radius),
          ),
        );
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 7.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
