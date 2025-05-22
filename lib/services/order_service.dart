// sumatra_jewelry_app/services/order_service.dart
import 'package:sumatra_jewelry_app/models/order.dart'; // Pastikan ini mengarah ke model Order Anda

class OrderService {
  // Ini adalah daftar dummy yang akan menyimpan pesanan Anda.
  // Menggunakan 'static final' memastikan bahwa daftar ini hanya dibuat sekali
  // dan dipertahankan di memori selama seluruh siklus hidup aplikasi.
  static final List<Order> _dummyOrders = [
    // Contoh data dummy awal (opsional, bisa dikosongkan jika ingin memulai dari nol)
    // Order(
    //   id: 1, // ID unik
    //   customerName: 'Budi Santoso',
    //   phoneNumber: '081234567890',
    //   address: 'Jl. Contoh No. 1, Jakarta',
    //   productName: '(Cincin) Cincin Berlian Klasik',
    //   productDescription: 'Cincin emas putih dengan berlian 1 karat.',
    //   goldType: 'Emas Putih 18K',
    //   diamondSize: '1 Karat',
    //   ringSize: '17',
    //   estimatedPrice: 15000000.0,
    //   status: 'pending', // Status awal 'pending' (lowercase)
    //   orderDate: DateTime(2025, 4, 15),
    //   currentWorkerRole: 'Sales',
    //   referenceImagePaths: [], // Bisa kosong jika tidak ada gambar
    //   lastUpdate: DateTime(2025, 4, 15),
    // ),
  ];

  // Mengelola ID unik secara otomatis untuk dummy data
  static int _nextId = 1; // Mulai dari ID 1, sesuaikan jika ada data dummy awal

  // Inisialisasi _nextId berdasarkan ID tertinggi yang sudah ada
  OrderService() {
    if (_dummyOrders.isNotEmpty) {
      _nextId =
          _dummyOrders
              .map((order) => order.id)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }
  }

  // Metode asli untuk mengambil semua pesanan (termasuk 'completed')
  // Ini adalah yang ingin Anda pertahankan agar tidak merah di tempat lain.
  Future<List<Order>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_dummyOrders); // Mengembalikan semua pesanan
  }

  // Metode baru untuk mengambil pesanan AKTIF (tidak berstatus 'completed')
  Future<List<Order>> getActiveOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyOrders.where((order) => order.status != 'completed').toList();
  }

  // Menambahkan pesanan baru
  Future<void> addOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Assign ID baru jika order.id adalah 0 atau belum diset
    Order newOrder = order.id == 0 ? order.copyWith(id: _nextId++) : order;
    _dummyOrders.add(newOrder);
    // Debugging print
    print(
      'OrderService: Pesanan "${newOrder.productName}" (ID: ${newOrder.id}) ditambahkan. Total: ${_dummyOrders.length}',
    );
  }

  // Memperbarui pesanan yang sudah ada
  Future<void> updateOrder(Order updatedOrder) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _dummyOrders.indexWhere(
      (order) => order.id == updatedOrder.id,
    );
    if (index != -1) {
      _dummyOrders[index] = updatedOrder;
      print(
        'OrderService: Pesanan "${updatedOrder.productName}" (ID: ${updatedOrder.id}) diperbarui. Status: ${updatedOrder.status}',
      );
    } else {
      print(
        'OrderService: Pesanan dengan ID ${updatedOrder.id} tidak ditemukan untuk diperbarui.',
      );
      throw Exception('Order not found');
    }
  }

  // Menghapus pesanan
  Future<void> deleteOrder(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final initialLength = _dummyOrders.length;
    _dummyOrders.removeWhere((order) => order.id == id);
    if (_dummyOrders.length < initialLength) {
      print(
        'OrderService: Pesanan dengan ID $id dihapus. Total: ${_dummyOrders.length}',
      );
    } else {
      print(
        'OrderService: Pesanan dengan ID $id tidak ditemukan untuk dihapus.',
      );
    }
  }

  // Anda bisa menambahkan method lain di sini sesuai kebutuhan,
  // misalnya getOrderById, filterOrdersByStatus, dll.
}
