import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../services/account_service.dart';
import '../../models/accounts.dart';

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
  String formatRupiah(num? value) {
    if (value == null || value == 0) return '-';
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

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
    'Pasang Batu',
    'Pengecekan',
  ];
  final List<String> finisherTasks = ['Chrome', 'Kasih ke Admin'];

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
      // Ambil ID user yang sedang login
      final String? currentUserIdStr = AuthService().currentUserId;
      final int? currentUserId =
          currentUserIdStr != null ? int.tryParse(currentUserIdStr) : null;

      // Debug: print untuk memastikan currentUserId ada
      print('DEBUG: currentUserIdStr = $currentUserIdStr');
      print('DEBUG: currentUserId = $currentUserId');

      // Buat map untuk field yang akan diupdate
      final Map<String, dynamic> updateFields = {
        'ordersWorkflowStatus': OrderWorkflowStatus.stoneSetting,
        'ordersDiamondSettingAccountId': currentUserId,
      };

      // Debug: print updateFields
      print('DEBUG: updateFields = $updateFields');

      // Hanya kirim field angka jika tidak null
      if (_order.ordersGoldPricePerGram != null) {
        updateFields['ordersGoldPricePerGram'] =
            _order.ordersGoldPricePerGram.toString();
      }
      if (_order.ordersFinalPrice != null) {
        updateFields['ordersFinalPrice'] = _order.ordersFinalPrice.toString();
      }
      if (_order.ordersDp != null) {
        updateFields['ordersDp'] = _order.ordersDp.toString();
      }
      // Copy order dengan field yang diupdate
      final updatedOrder = _order.copyWith(
        ordersWorkflowStatus: updateFields['ordersWorkflowStatus'],
        ordersDiamondSettingAccountId:
            updateFields['ordersDiamondSettingAccountId'],
        ordersGoldPricePerGram: _order.ordersGoldPricePerGram,
        ordersFinalPrice: _order.ordersFinalPrice,
        ordersDp: _order.ordersDp,
      );

      // Debug: print updatedOrder
      print(
        'DEBUG: updatedOrder.ordersDiamondSettingAccountId = ${updatedOrder.ordersDiamondSettingAccountId}',
      );

      final result = await OrderService().updateOrder(updatedOrder);
      if (result == true) {
        setState(() {
          _order = updatedOrder;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan masuk tahap Stone Setting')),
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

  Widget _buildChecklistWithAccount(
    BuildContext context,
    String title,
    List<String> defaultTasks,
    List<String>? checkedTasks,
    IconData icon,
    Color color,
    int? accountId,
  ) {
    final checked = checkedTasks ?? [];
    return FutureBuilder<Account?>(
      future:
          accountId != null
              ? AccountService.getAccountById(accountId)
              : Future.value(null),
      builder: (ctx, snapshot) {
        String? userName;
        if (accountId != null && snapshot.hasData && snapshot.data != null) {
          userName = snapshot.data!.accountsName;
        }
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
                if (userName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Dikerjakan oleh: $userName',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
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
                                ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
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
      },
    );
  }

  Widget _buildStoneInfo() {
    final stoneList = _order.ordersStoneUsed;
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
      constraints: const BoxConstraints(
        minHeight: 120,
        maxHeight: 150, // Batasan maksimal yang fleksibel
      ),
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
            maxLines: 2, // Izinkan maksimal 2 baris untuk teks yang panjang
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
                'Tanggal Siap: ${_order.ordersReadyDate != null ? "${_order.ordersReadyDate!.day.toString().padLeft(2, '0')}/${_order.ordersReadyDate!.month.toString().padLeft(2, '0')}/${_order.ordersReadyDate!.year}" : "-"}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Pickup: ${_order.ordersPickupDate != null ? "${_order.ordersPickupDate!.day.toString().padLeft(2, '0')}/${_order.ordersPickupDate!.month.toString().padLeft(2, '0')}/${_order.ordersPickupDate!.year}" : "-"}',
                  ),
                  Text(
                    'Tanggal Dibuat: ${_order.ordersCreatedAt.day.toString().padLeft(2, '0')}/${_order.ordersCreatedAt.month.toString().padLeft(2, '0')}/${_order.ordersCreatedAt.year}',
                  ),
                  Text(
                    'Terakhir Update: ${_order.ordersUpdatedAt != null ? "${_order.ordersUpdatedAt!.day.toString().padLeft(2, '0')}/${_order.ordersUpdatedAt!.month.toString().padLeft(2, '0')}/${_order.ordersUpdatedAt!.year}" : "-"}',
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
                  // Jika tab onprogress, tampilkan semua checklist untuk tracking
                  if (widget.fromTab == 'onprogress') ...[
                    _buildChecklistWithAccount(
                      context,
                      'Designer',
                      designerTasks,
                      _order.ordersDesignerWorkChecklist,
                      Icons.design_services,
                      Colors.blue,
                      _order.ordersDesignerAccountId,
                    ),
                    _buildChecklistWithAccount(
                      context,
                      'Cor',
                      corTasks,
                      _order.ordersCastingWorkChecklist,
                      Icons.local_fire_department,
                      Colors.orange,
                      _order.ordersCastingAccountId,
                    ),
                    _buildChecklistWithAccount(
                      context,
                      'Carver',
                      carverTasks,
                      _order.ordersCarvingWorkChecklist,
                      Icons.handyman,
                      Colors.brown,
                      _order.ordersCarvingAccountId,
                    ),
                    _buildChecklistWithAccount(
                      context,
                      'Diamond Setter',
                      diamondSetterTasks,
                      _order.ordersDiamondSettingWorkChecklist,
                      Icons.diamond,
                      Colors.purple,
                      _order.ordersDiamondSettingAccountId,
                    ),
                    _buildChecklistWithAccount(
                      context,
                      'Finisher',
                      finisherTasks,
                      _order.ordersFinishingWorkChecklist,
                      Icons.check_circle,
                      Colors.green,
                      _order.ordersFinishingAccountId,
                    ),
                  ] else ...[
                    // Untuk tab lain, tampilkan hanya checklist diamond setter
                    _buildChecklistWithAccount(
                      context,
                      'Diamond Setter',
                      diamondSetterTasks,
                      _order.ordersDiamondSettingWorkChecklist,
                      Icons.diamond,
                      Colors.purple,
                      _order.ordersDiamondSettingAccountId,
                    ),
                  ],
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
                  ...diamondSetterTasks.map(
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
                          diamondSetterTasks.length &&
                      _diamondSetterChecklist.toSet().containsAll(
                        diamondSetterTasks.toSet(),
                      ) &&
                      _order.ordersDiamondSettingWorkChecklist.length ==
                          diamondSetterTasks.length &&
                      _order.ordersDiamondSettingWorkChecklist
                          .toSet()
                          .containsAll(diamondSetterTasks.toSet()))
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
