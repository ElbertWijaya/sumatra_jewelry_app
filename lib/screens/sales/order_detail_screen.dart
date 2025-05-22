// sumatra_jewelry_app/lib/screens/sales/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart'; // Import model Order yang sudah diperbarui
import 'package:sumatra_jewelry_app/services/order_service.dart'; // Import OrderService

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  final String userRole; // Menerima peran pengguna

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.userRole,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  late Order _currentOrder; // Untuk menyimpan state order yang bisa berubah
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  // Fungsi untuk mendapatkan opsi status yang valid berdasarkan peran
  List<DropdownMenuItem<OrderStatus>> _getValidStatusOptions() {
    List<OrderStatus> allowedStatuses = [];

    // Logika validasi transisi status berdasarkan peran
    // Ini adalah VALIDASI FRONTEND, backend HARUS melakukan validasi ulang.
    switch (widget.userRole) {
      case 'sales':
        // Sales dapat mengubah pending ke assigned_to_designer, atau membatalkan pesanan
        if (_currentOrder.status == OrderStatus.pending) {
          allowedStatuses.add(OrderStatus.pending); // Tetap bisa dipilih
          allowedStatuses.add(OrderStatus.assignedToDesigner);
          allowedStatuses.add(OrderStatus.canceled);
        } else if (_currentOrder.status == OrderStatus.readyForPickup) {
          allowedStatuses.add(OrderStatus.readyForPickup); // Tetap bisa dipilih
          allowedStatuses.add(OrderStatus.completed);
        } else {
          // Sales hanya bisa melihat status lain, tidak mengubahnya (kecuali pembatalan dari pending)
          allowedStatuses.add(_currentOrder.status);
        }
        break;
      case 'designer':
        if (_currentOrder.status == OrderStatus.assignedToDesigner) {
          allowedStatuses.add(OrderStatus.assignedToDesigner);
          allowedStatuses.add(OrderStatus.designing);
        } else if (_currentOrder.status == OrderStatus.designing) {
          allowedStatuses.add(OrderStatus.designing);
          allowedStatuses.add(OrderStatus.readyForCor);
        } else {
          allowedStatuses.add(_currentOrder.status);
        }
        break;
      case 'cor':
        if (_currentOrder.status == OrderStatus.readyForCor) {
          allowedStatuses.add(OrderStatus.readyForCor);
          allowedStatuses.add(OrderStatus.corInProgress);
        } else if (_currentOrder.status == OrderStatus.corInProgress) {
          allowedStatuses.add(OrderStatus.corInProgress);
          allowedStatuses.add(OrderStatus.readyForCarving);
        } else {
          allowedStatuses.add(_currentOrder.status);
        }
        break;
      case 'carver':
        if (_currentOrder.status == OrderStatus.readyForCarving) {
          allowedStatuses.add(OrderStatus.readyForCarving);
          allowedStatuses.add(OrderStatus.carvingInProgress);
        } else if (_currentOrder.status == OrderStatus.carvingInProgress) {
          allowedStatuses.add(OrderStatus.carvingInProgress);
          allowedStatuses.add(OrderStatus.readyForDiamondSetting);
        } else {
          allowedStatuses.add(_currentOrder.status);
        }
        break;
      case 'diamond_setter':
        if (_currentOrder.status == OrderStatus.readyForDiamondSetting) {
          allowedStatuses.add(OrderStatus.readyForDiamondSetting);
          allowedStatuses.add(OrderStatus.diamondSettingInProgress);
        } else if (_currentOrder.status == OrderStatus.diamondSettingInProgress) {
          allowedStatuses.add(OrderStatus.diamondSettingInProgress);
          allowedStatuses.add(OrderStatus.readyForFinishing);
        } else {
          allowedStatuses.add(_currentOrder.status);
        }
        break;
      case 'finisher':
        if (_currentOrder.status == OrderStatus.readyForFinishing) {
          allowedStatuses.add(OrderStatus.readyForFinishing);
          allowedStatuses.add(OrderStatus.finishingInProgress);
        } else if (_currentOrder.status == OrderStatus.finishingInProgress) {
          allowedStatuses.add(OrderStatus.finishingInProgress);
          allowedStatuses.add(OrderStatus.readyForPickup);
        } else {
          allowedStatuses.add(_currentOrder.status);
        }
        break;
      case 'repairer':
        // Repairer mungkin memiliki alur yang berbeda, misalnya dari completed ke repair_in_progress, lalu kembali ke ready_for_pickup/completed
        // Ini contoh saja, sesuaikan dengan alur repair Anda
        if (_currentOrder.status == OrderStatus.completed) { // Misal pesanan completed bisa di repair
          allowedStatuses.add(OrderStatus.completed);
          // Tambahkan status 'repair_in_progress' jika ada di enum Anda
        } else {
          allowedStatuses.add(_currentOrder.status);
        }
        break;
      case 'boss':
        // Boss bisa melihat semua status, mungkin tidak bisa mengubah langsung
        allowedStatuses = OrderStatus.values.toList(); // Boss bisa melihat semua
        break;
      case 'inventory':
        // Inventory mungkin tidak mengubah status pesanan secara langsung
        allowedStatuses.add(_currentOrder.status);
        break;
      default:
        allowedStatuses.add(_currentOrder.status); // Default: hanya status saat ini
        break;
    }

    // Filter agar hanya menampilkan status saat ini + status transisi yang valid
    // dan hindari duplikasi jika status saat ini juga ada di allowedStatuses
    final uniqueStatuses = allowedStatuses.toSet().toList()
      ..sort((a, b) => a.index.compareTo(b.index)); // Urutkan berdasarkan index enum

    return uniqueStatuses.map((status) {
      return DropdownMenuItem<OrderStatus>(
        value: status,
        child: Text(status.toDisplayString()),
      );
    }).toList();
  }

  // Fungsi untuk memperbarui status pesanan
  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    if (newStatus == _currentOrder.status) {
      // Tidak perlu update jika status tidak berubah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status tidak berubah.')),
      );
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      // Lakukan validasi transisi di frontend sebelum memanggil service
      // Ini adalah validasi UI/UX, bukan validasi keamanan utama
      if (!_getValidStatusOptions().any((item) => item.value == newStatus)) {
        throw Exception('Transisi status tidak valid untuk peran Anda.');
      }

      await _orderService.updateOrderStatus(_currentOrder.id, newStatus);
      setState(() {
        _currentOrder = _currentOrder.copyWith(status: newStatus);
      });
      // Beri tahu dashboard sebelumnya bahwa ada perubahan
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    } finally {
      setState(() {
        _isUpdatingStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pesanan ID: ${_currentOrder.id}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                'Pelanggan: ${_currentOrder.customerName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              Text(
                'Produk: ${_currentOrder.productName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              Text(
                'Total Harga: Rp${_currentOrder.totalPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              Text(
                'Tanggal Pesanan: ${_currentOrder.orderDate.toLocal().toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 15),
              // Bagian untuk menampilkan dan mengubah status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status Saat Ini:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _isUpdatingStatus
                      ? const CircularProgressIndicator()
                      : DropdownButton<OrderStatus>(
                          value: _currentOrder.status,
                          items: _getValidStatusOptions(),
                          onChanged: (OrderStatus? newValue) {
                            if (newValue != null) {
                              _updateOrderStatus(newValue);
                            }
                          },
                          // Menonaktifkan dropdown jika bukan peran yang relevan atau sedang update
                          // Ini hanya contoh, sesuaikan dengan aturan bisnis Anda.
                          // Misal, hanya sales/finisher/designer yang bisa mengubah status tertentu
                          // Anda bisa lebih spesifik di _getValidStatusOptions
                          // isEnabled: _getValidStatusOptions().isNotEmpty &&
                          //     (widget.userRole == 'finisher' || widget.userRole == 'sales'),
                        ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Catatan: ${_currentOrder.notes ?? '-'}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 15),
              _currentOrder.imageUrl != null
                  ? Image.asset(
                      _currentOrder.imageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const Text('Tidak ada gambar produk'),
              // Tambahan informasi lain yang mungkin relevan
              // Misalnya, riwayat perubahan status, detail item, dll.
            ],
          ),
        ),
      ),
    );
  }
}