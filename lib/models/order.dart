// sumatra_jewelry_app/lib/models/order.dart

// Enum untuk mendefinisikan semua status pesanan yang mungkin
enum OrderStatus {
  pending,
  assignedToDesigner,
  designing,
  readyForCor,
  corInProgress,
  readyForCarving,
  carvingInProgress,
  readyForDiamondSetting,
  diamondSettingInProgress,
  readyForFinishing,
  finishingInProgress,
  readyForPickup,
  completed, // Status akhir setelah diambil
  canceled, // Jika pesanan dibatalkan
}

// Extension untuk mengubah enum menjadi string yang lebih mudah dibaca di UI
extension OrderStatusExtension on OrderStatus {
  String toDisplayString() {
    // Memperbaiki ini agar sesuai dengan format yang saya gunakan di dashboard
    // Misalnya, 'assignedToDesigner' menjadi 'Assigned to Designer'
    // Menggunakan regex untuk menambahkan spasi sebelum huruf kapital dan mengubah menjadi Title Case
    // Kemudian menangani beberapa kasus spesifik yang saya gunakan di dashboard
    switch (this) {
      case OrderStatus.pending:
        return 'Waiting'; // Sesuai dengan filter 'Waiting'
      case OrderStatus.completed:
        return 'Submitted'; // Sesuai dengan filter 'Submitted'
      default:
        // Untuk status lain, ubah 'camelCase' menjadi 'Title Case with spaces'
        return name.replaceAllMapped(
          RegExp(r'(?<=[a-z])[A-Z]'),
          (match) => ' ${match.group(0)!}',
        ).replaceAll(RegExp(r'_'), ' ').split(' ').map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
    }
  }
}

class Order {
  final String id;
  final String customerName;
  final String productName;
  final double totalPrice;
  final OrderStatus status; // Gunakan enum OrderStatus
  final DateTime orderDate;
  final DateTime lastUpdated; // <--- TIDAK PERLU 'late' jika diberikan di konstruktor atau factory
  final String? notes; // Catatan tambahan, bisa null
  final String? imageUrl; // URL gambar produk, bisa null
  final String? assignedTo; // ID/Nama karyawan yang ditugaskan

  Order({
    required this.id,
    required this.customerName,
    required this.productName,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    required this.lastUpdated, // <--- TAMBAHKAN INI DI KONSTRUKTOR
    this.notes,
    this.imageUrl,
    this.assignedTo,
  });

  // Factory constructor untuk membuat objek Order dari JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      productName: json['productName'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      // Konversi string status dari JSON ke enum
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending, // Default jika status tidak dikenali
      ),
      orderDate: DateTime.parse(json['orderDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String), // <--- TAMBAHKAN INI DI FROMJSON
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      assignedTo: json['assignedTo'] as String?,
    );
  }

  // Metode untuk mengubah objek Order menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'productName': productName,
      'totalPrice': totalPrice,
      'status': status.name, // Ubah enum kembali ke string untuk JSON
      'orderDate': orderDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(), // <--- TAMBAHKAN INI DI TOJSON
      'notes': notes,
      'imageUrl': imageUrl,
      'assignedTo': assignedTo,
    };
  }

  // Metode copyWith untuk membuat salinan objek dengan perubahan tertentu
  Order copyWith({
    String? id,
    String? customerName,
    String? productName,
    double? totalPrice,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? lastUpdated, // <--- TAMBAHKAN INI DI COPYWITH
    String? notes,
    String? imageUrl,
    String? assignedTo,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      productName: productName ?? this.productName,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      lastUpdated: lastUpdated ?? this.lastUpdated, // <--- DAN INI DI COPYWITH
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}