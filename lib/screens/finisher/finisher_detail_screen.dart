import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../services/account_service.dart';
import '../../models/accounts.dart';

class FinisherDetailScreen extends StatefulWidget {
  final Order order;
  final String fromTab; // 'waiting', 'working', 'onprogress'
  final List<String> finisherTasks;
  const FinisherDetailScreen({
    super.key,
    required this.order,
    required this.fromTab,
    required this.finisherTasks,
  });

  @override
  State<FinisherDetailScreen> createState() => _FinisherDetailScreenState();
}

class _FinisherDetailScreenState extends State<FinisherDetailScreen> {
  String formatRupiah(num? value) {
    if (value == null || value == 0) return '-';
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Definisi task untuk semua role - konsisten dengan file lainnya
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
  List<String> _finisherChecklist = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _finisherChecklist = List<String>.from(_order.ordersFinishingWorkChecklist);
    // Fetch latest data dari database ketika screen dibuka
    _refreshOrderData();
  }

  Future<void> _refreshOrderData() async {
    try {
      final refreshedOrder = await OrderService().getOrderById(_order.ordersId);
      setState(() {
        _order = refreshedOrder;
        _finisherChecklist = List<String>.from(
          refreshedOrder.ordersFinishingWorkChecklist,
        );
      });
    } catch (e) {
      // Jika gagal fetch, tetap gunakan data yang ada
      print('Failed to refresh order data: $e');
    }
  }

  Future<void> _startFinishing() async {
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
        'ordersWorkflowStatus': OrderWorkflowStatus.finishing,
        'ordersFinishingAccountId': currentUserId,
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
        ordersFinishingAccountId: updateFields['ordersFinishingAccountId'],
        ordersGoldPricePerGram: _order.ordersGoldPricePerGram,
        ordersFinalPrice: _order.ordersFinalPrice,
        ordersDp: _order.ordersDp,
      );

      // Debug: print updatedOrder
      print(
        'DEBUG: updatedOrder.ordersFinishingAccountId = ${updatedOrder.ordersFinishingAccountId}',
      );

      final result = await OrderService().updateOrder(updatedOrder);
      if (result == true) {
        setState(() {
          _order = updatedOrder;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan masuk tahap Finishing')),
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
        ordersFinishingWorkChecklist: _finisherChecklist,
      );
      await OrderService().updateOrder(updatedOrder);
      setState(() {
        _order = updatedOrder;
        _finisherChecklist = List<String>.from(
          updatedOrder.ordersFinishingWorkChecklist,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checklist berhasil diupdate!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _submitToInventory() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        ordersWorkflowStatus: OrderWorkflowStatus.waitingInventory,
      );
      await OrderService().updateOrder(updatedOrder);
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan dikirim ke Inventory!')),
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
                  const SizedBox(height: 2),
                  Text(
                    'Dikerjakan oleh $userName',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                // Tambahkan status inventory di dalam card Inventory
                if (title == 'Inventory' && accountId != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pesanan ini sudah memiliki data inventory lengkap dan siap untuk tahap sales completion.',
                          style: TextStyle(
                            color: Colors.green[900],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(
                  minWidth: 120, // Lebar minimum untuk readability
                  maxWidth:
                      200, // Lebar maksimal untuk mencegah card terlalu lebar
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.diamond, color: Colors.amber[700], size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Batu ${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.amber[800],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStoneDetailRow(
                      'Bentuk',
                      stone['shape'] ?? '-',
                      Icons.category,
                    ),
                    const SizedBox(height: 8),
                    _buildStoneDetailRow(
                      'Jumlah',
                      '${stone['count'] ?? '-'} pcs',
                      Icons.confirmation_number,
                    ),
                    const SizedBox(height: 8),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
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
                      : 'http://192.168.7.25/sumatra_api/orders_photo/$img';
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
                      const Color.fromARGB(255, 167, 228, 25),
                      _order.ordersFinishingAccountId,
                    ),
                    _buildChecklistWithAccount(
                      context,
                      'Inventory',
                      [], // Tidak ada checklist inventory, hanya status
                      null,
                      Icons.inventory,
                      Colors.teal,
                      _order.ordersInventoryAccountId,
                    ),
                  ] else ...[
                    // Untuk tab lain, tampilkan hanya checklist finisher
                    _buildChecklistWithAccount(
                      context,
                      'Finisher',
                      finisherTasks,
                      _order.ordersFinishingWorkChecklist,
                      Icons.check_circle,
                      const Color.fromARGB(255, 167, 228, 25),
                      _order.ordersFinishingAccountId,
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
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Mulai Finishing',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: _isProcessing ? null : _startFinishing,
                  ),
                ),
              ),
            if (widget.fromTab == 'working')
              Column(
                children: [
                  ...finisherTasks.map(
                    (task) => CheckboxListTile(
                      value: _finisherChecklist.contains(task),
                      title: Text(task),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _finisherChecklist.add(task);
                          } else {
                            _finisherChecklist.remove(task);
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
                  if (_finisherChecklist.length == finisherTasks.length &&
                      _finisherChecklist.toSet().containsAll(
                        finisherTasks.toSet(),
                      ) &&
                      _order.ordersFinishingWorkChecklist.length ==
                          finisherTasks.length &&
                      _order.ordersFinishingWorkChecklist.toSet().containsAll(
                        finisherTasks.toSet(),
                      ))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            167,
                            228,
                            25,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.send),
                        label: const Text(
                          'Submit ke Inventory',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed: _isProcessing ? null : _submitToInventory,
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
