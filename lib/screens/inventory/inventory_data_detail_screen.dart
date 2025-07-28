import 'package:flutter/material.dart';
import '../../models/inventory.dart';
import 'inventory_data_edit_screen.dart';

class InventoryDataDetailScreen extends StatefulWidget {
  final Inventory inventory;

  const InventoryDataDetailScreen({super.key, required this.inventory});

  @override
  State<InventoryDataDetailScreen> createState() =>
      _InventoryDataDetailScreenState();
}

class _InventoryDataDetailScreenState extends State<InventoryDataDetailScreen> {
  late Inventory _inventory;

  @override
  void initState() {
    super.initState();
    _inventory = widget.inventory;
  }

  String formatRupiah(String? value) {
    if (value == null || value.isEmpty || value == '0') return '-';
    final numValue = double.tryParse(value) ?? 0;
    return 'Rp ${numValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildStoneInfo() {
    final stoneList = _inventory.InventoryStoneUsed;
    if (stoneList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Text(
          'Tidak ada informasi batu',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120, maxHeight: 150),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: stoneList.length,
        itemBuilder: (context, index) {
          final stone = stoneList[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color(0xFFFFF8E1),
              child: Container(
                width: 130,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStoneDetailRow(
                      'Bentuk',
                      stone['shape'] ?? '-',
                      Icons.category,
                    ),
                    const SizedBox(height: 6),
                    _buildStoneDetailRow(
                      'Jumlah',
                      '${stone['count'] ?? '-'} pcs',
                      Icons.confirmation_number,
                    ),
                    const SizedBox(height: 6),
                    _buildStoneDetailRow(
                      'Ukuran',
                      '${stone['carat'] ?? '-'} ct',
                      Icons.straighten,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoneDetailRow(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.amber[600]),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.amber[800],
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    if (_inventory.InventoryImagePaths.isEmpty) {
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
            _inventory.InventoryImagePaths.map((img) {
              final String imageUrl =
                  img.startsWith('http')
                      ? img
                      : 'http://192.168.7.25/sumatra_api/inventory_photo/$img';
              return GestureDetector(
                onTap: () {
                  // Bisa ditambahkan preview gambar full screen di sini
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
        title: const Text('Detail Data Inventory'),
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          InventoryDataEditScreen(inventory: _inventory),
                ),
              );
              if (result != null && result is Inventory) {
                setState(() {
                  _inventory = result;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Dasar
            Text(
              'Informasi Dasar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.inventory, color: Colors.teal),
                      title: Text('ID Inventory'),
                      subtitle: Text(_inventory.InventoryId),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.shopping_bag, color: Colors.amber),
                      title: Text('ID Produk'),
                      subtitle: Text(_inventory.InventoryProductId),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.category, color: Colors.blue),
                      title: Text('Jenis Perhiasan'),
                      subtitle: Text(_inventory.InventoryJewelryType ?? '-'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Informasi Material
            Text(
              'Informasi Material',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.star, color: Colors.yellow[700]),
                      title: Text('Jenis Emas'),
                      subtitle: Text(_inventory.InventoryGoldType ?? '-'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.palette, color: Colors.orange),
                      title: Text('Warna Emas'),
                      subtitle: Text(_inventory.InventoryGoldColor ?? '-'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.straighten, color: Colors.purple),
                      title: Text('Ukuran Ring'),
                      subtitle: Text(_inventory.InventoryRingSize ?? '-'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Informasi Harga
            Text(
              'Informasi Harga',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.attach_money, color: Colors.green),
                  title: Text('Harga Item'),
                  subtitle: Text(formatRupiah(_inventory.InventoryItemsPrice)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Informasi Batu
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
            const SizedBox(height: 16),

            // Gambar
            Text(
              'Gambar Inventory',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            _buildImageGallery(),
            const SizedBox(height: 16),

            // Informasi Tanggal
            Text(
              'Informasi Tanggal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 6),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.calendar_today, color: Colors.blue),
                      title: Text('Tanggal Dibuat'),
                      subtitle: Text(formatDate(_inventory.InventoryCreatedAt)),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.update, color: Colors.orange),
                      title: Text('Terakhir Diupdate'),
                      subtitle: Text(formatDate(_inventory.InventoryUpdatedAt)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
