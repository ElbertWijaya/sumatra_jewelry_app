import 'package:flutter/material.dart';
import '../../models/order.dart';

class SalesDetailScreen extends StatelessWidget {
  const SalesDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ambil order dari arguments
    final Order order = ModalRoute.of(context)?.settings.arguments as Order;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Nama Pelanggan'),
            subtitle: Text(order.customerName),
          ),
          ListTile(
            title: const Text('Nomor Telepon'),
            subtitle: Text(order.customerContact),
          ),
          ListTile(title: const Text('Alamat'), subtitle: Text(order.address)),
          ListTile(
            title: const Text('Jenis Perhiasan'),
            subtitle: Text(order.jewelryType),
          ),
          if (order.stoneType != null && order.stoneType!.isNotEmpty)
            ListTile(
              title: const Text('Jenis Batu'),
              subtitle: Text(order.stoneType ?? '-'),
            ),
          if (order.stoneSize != null && order.stoneSize!.isNotEmpty)
            ListTile(
              title: const Text('Ukuran Batu'),
              subtitle: Text(order.stoneSize ?? '-'),
            ),
          if (order.ringSize != null && order.ringSize!.isNotEmpty)
            ListTile(
              title: const Text('Ukuran Cincin'),
              subtitle: Text(order.ringSize ?? '-'),
            ),
          if (order.goldPricePerGram != null)
            ListTile(
              title: const Text('Harga Emas per Gram'),
              subtitle: Text(order.goldPricePerGram?.toString() ?? '-'),
            ),
          if (order.finalPrice != null)
            ListTile(
              title: const Text('Harga Akhir'),
              subtitle: Text(order.finalPrice?.toString() ?? '-'),
            ),
          if (order.readyDate != null)
            ListTile(
              title: const Text('Tanggal Siap'),
              subtitle: Text(
                order.readyDate?.toLocal().toString().split(' ')[0] ?? '-',
              ),
            ),
          if (order.pickupDate != null)
            ListTile(
              title: const Text('Tanggal Ambil'),
              subtitle: Text(
                order.pickupDate?.toLocal().toString().split(' ')[0] ?? '-',
              ),
            ),
          if (order.notes != null && order.notes!.isNotEmpty)
            ListTile(
              title: const Text('Catatan'),
              subtitle: Text(order.notes ?? '-'),
            ),
          ListTile(
            title: const Text('Status Pesanan'),
            subtitle: Text(order.workflowStatus.label),
          ),
          ListTile(
            title: const Text('Tanggal Order'),
            subtitle: Text(order.createdAt.toLocal().toString().split(' ')[0]),
          ),
          if (order.updatedAt != null)
            ListTile(
              title: const Text('Terakhir Diperbarui'),
              subtitle: Text(
                order.updatedAt?.toLocal().toString().split(' ')[0] ?? '-',
              ),
            ),
          // Assignment per divisi, jika ada
          if (order.assignedDesigner != null)
            ListTile(
              title: const Text('Designer'),
              subtitle: Text(order.assignedDesigner!),
            ),
          if (order.assignedCaster != null)
            ListTile(
              title: const Text('Tukang Cor'),
              subtitle: Text(order.assignedCaster!),
            ),
          if (order.assignedCarver != null)
            ListTile(
              title: const Text('Carver'),
              subtitle: Text(order.assignedCarver!),
            ),
          if (order.assignedDiamondSetter != null)
            ListTile(
              title: const Text('Diamond Setter'),
              subtitle: Text(order.assignedDiamondSetter!),
            ),
          if (order.assignedFinisher != null)
            ListTile(
              title: const Text('Finisher'),
              subtitle: Text(order.assignedFinisher!),
            ),
          if (order.assignedInventory != null)
            ListTile(
              title: const Text('Inventaris'),
              subtitle: Text(order.assignedInventory!),
            ),
        ],
      ),
    );
  }
}
