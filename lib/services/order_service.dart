// sumatra_jewelry_app/lib/services/order_service.dart
import 'dart:convert'; // Untuk json.decode
import 'package:http/http.dart' as http; // Pastikan Anda memiliki package http di pubspec.yaml
import 'package:sumatra_jewelry_app/models/order.dart'; // Import model Order yang sudah diperbarui

class OrderService {
  // Ganti dengan URL API backend Anda yang sebenarnya
  // Contoh: const String _baseUrl = 'http://localhost:3000/api/orders';
  // Untuk simulasi:
  static const String _baseUrl = 'https://mocki.io/v1/a570c918-a400-4b2a-8b8a-3e5f2998a4e3'; // URL dummy untuk GET orders
  static const String _updateUrl = 'https://api.example.com/orders/'; // Ganti dengan URL API update Anda

  // Dummy data untuk simulasi (akan dihapus saat terhubung ke backend sungguhan)
  List<Order> _dummyOrders = [
    Order(
      id: 'ORD001',
      customerName: 'Budi Santoso',
      productName: 'Cincin Berlian',
      totalPrice: 15000000,
      status: OrderStatus.readyForFinishing,
      orderDate: DateTime(2023, 10, 26, 10, 30),
      notes: 'Ukuran 17, grafir B&S',
      imageUrl: 'assets/placeholder_jewelry_1.jpg',
      assignedTo: 'Finisher A',
    ),
    Order(
      id: 'ORD002',
      customerName: 'Siti Aminah',
      productName: 'Kalung Emas',
      totalPrice: 8000000,
      status: OrderStatus.finishingInProgress,
      orderDate: DateTime(2023, 10, 25, 14, 0),
      notes: 'Panjang 45cm',
      imageUrl: 'assets/placeholder_jewelry_2.jpg',
      assignedTo: 'Finisher A',
    ),
    Order(
      id: 'ORD003',
      customerName: 'Joko Susanto',
      productName: 'Anting Mutiara',
      totalPrice: 6000000,
      status: OrderStatus.readyForPickup,
      orderDate: DateTime(2023, 10, 24, 9, 0),
      notes: 'Mutiara air tawar',
      imageUrl: 'assets/placeholder_jewelry_3.jpg',
      assignedTo: 'Sales B',
    ),
    Order(
      id: 'ORD004',
      customerName: 'Maria Chandra',
      productName: 'Gelang Perak',
      totalPrice: 3500000,
      status: OrderStatus.pending,
      orderDate: DateTime(2023, 10, 23, 11, 45),
      notes: 'Ukiran nama',
      imageUrl: 'assets/placeholder_jewelry_4.jpg',
      assignedTo: null,
    ),
    Order(
      id: 'ORD005',
      customerName: 'Ahmad Khoirul',
      productName: 'Liontin Nama',
      totalPrice: 4200000,
      status: OrderStatus.designing,
      orderDate: DateTime(2023, 10, 22, 16, 0),
      notes: 'Desain kaligrafi',
      imageUrl: 'assets/placeholder_jewelry_1.jpg',
      assignedTo: 'Designer X',
    ),
    Order(
      id: 'ORD006',
      customerName: 'Dewi Lestari',
      productName: 'Cincin Tunangan',
      totalPrice: 20000000,
      status: OrderStatus.corInProgress,
      orderDate: DateTime(2023, 10, 21, 13, 15),
      notes: 'Emas putih, batu zamrud',
      imageUrl: 'assets/placeholder_jewelry_2.jpg',
      assignedTo: 'COR Y',
    ),
     Order(
      id: 'ORD007',
      customerName: 'Rina Wijaya',
      productName: 'Gelang Berlian',
      totalPrice: 18000000,
      status: OrderStatus.carvingInProgress,
      orderDate: DateTime(2023, 10, 20, 10, 0),
      notes: 'Model klasik',
      imageUrl: 'assets/placeholder_jewelry_3.jpg',
      assignedTo: 'Carver P',
    ),
    Order(
      id: 'ORD008',
      customerName: 'Kevin Leonardo',
      productName: 'Anting Berlian',
      totalPrice: 12000000,
      status: OrderStatus.diamondSettingInProgress,
      orderDate: DateTime(2023, 10, 19, 15, 30),
      notes: 'Berlian tabur',
      imageUrl: 'assets/placeholder_jewelry_4.jpg',
      assignedTo: 'Setter Q',
    ),
    Order(
      id: 'ORD009',
      customerName: 'Putri Indah',
      productName: 'Cincin Kawin',
      totalPrice: 25000000,
      status: OrderStatus.completed,
      orderDate: DateTime(2023, 10, 18, 11, 0),
      notes: 'Sudah diambil',
      imageUrl: 'assets/placeholder_jewelry_1.jpg',
      assignedTo: 'Sales C',
    ),
    Order(
      id: 'ORD010',
      customerName: 'Dani Pratama',
      productName: 'Kalung Nama',
      totalPrice: 5000000,
      status: OrderStatus.canceled,
      orderDate: DateTime(2023, 10, 17, 10, 0),
      notes: 'Dibatalkan oleh pelanggan',
      imageUrl: 'assets/placeholder_jewelry_2.jpg',
      assignedTo: 'Sales A',
    ),
  ];


  Future<List<Order>> getOrders() async {
    // Simulasi penundaan jaringan
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Jika Anda memiliki backend nyata, gunakan http.get
      // final response = await http.get(Uri.parse(_baseUrl));
      // if (response.statusCode == 200) {
      //   List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => Order.fromJson(json)).toList();
      // } else {
      //   throw Exception('Gagal memuat pesanan. Status: ${response.statusCode}');
      // }

      // Untuk saat ini, kembalikan dummy data
      return _dummyOrders;
    } catch (e) {
      // Penanganan error jaringan atau parsing
      throw Exception('Terjadi masalah saat memuat pesanan: $e');
    }
  }

  // Metode untuk memperbarui status pesanan
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    // Simulasi penundaan jaringan
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Cari pesanan dalam dummy data
      final index = _dummyOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        // Buat salinan pesanan dengan status baru
        _dummyOrders[index] = _dummyOrders[index].copyWith(status: newStatus);
        print('Pesanan $orderId berhasil diupdate menjadi ${newStatus.toDisplayString()}');
      } else {
        throw Exception('Pesanan dengan ID $orderId tidak ditemukan.');
      }

      // Jika Anda memiliki backend nyata, gunakan http.put atau http.post
      // final response = await http.put(
      //   Uri.parse('$_updateUrl$orderId'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'status': newStatus.name}), // Kirim nama enum
      // );
      //
      // if (response.statusCode != 200) {
      //   throw Exception('Gagal memperbarui status pesanan. Status: ${response.statusCode}');
      // }
    } catch (e) {
      throw Exception('Terjadi masalah saat memperbarui status pesanan: $e');
    }
  }

  // Metode untuk membuat pesanan baru (contoh, sesuaikan jika diperlukan)
  Future<Order> createOrder(Order newOrder) async {
    // Simulasi penundaan jaringan
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Menambahkan pesanan baru ke dummy data
      _dummyOrders.add(newOrder);
      print('Pesanan baru ${newOrder.id} berhasil ditambahkan.');
      return newOrder;

      // Jika Anda memiliki backend nyata
      // final response = await http.post(
      //   Uri.parse(_baseUrl),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode(newOrder.toJson()),
      // );
      //
      // if (response.statusCode == 201) { // 201 Created
      //   return Order.fromJson(json.decode(response.body));
      // } else {
      //   throw Exception('Gagal membuat pesanan baru. Status: ${response.statusCode}');
      // }
    } catch (e) {
      throw Exception('Terjadi masalah saat membuat pesanan: $e');
    }
  }

  // Metode untuk menghapus pesanan (contoh, sesuaikan jika diperlukan)
  Future<void> deleteOrder(String orderId) async {
    // Simulasi penundaan jaringan
    await Future.delayed(const Duration(seconds: 1));

    try {
      final initialLength = _dummyOrders.length;
      _dummyOrders.removeWhere((order) => order.id == orderId);
      if (_dummyOrders.length == initialLength) {
        throw Exception('Pesanan dengan ID $orderId tidak ditemukan untuk dihapus.');
      }
      print('Pesanan $orderId berhasil dihapus.');

      // Jika Anda memiliki backend nyata
      // final response = await http.delete(Uri.parse('$_baseUrl/$orderId'));
      // if (response.statusCode != 200) {
      //   throw Exception('Gagal menghapus pesanan. Status: ${response.statusCode}');
      // }
    } catch (e) {
      throw Exception('Terjadi masalah saat menghapus pesanan: $e');
    }
  }
}