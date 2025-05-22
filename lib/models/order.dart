// sumatra_jewelry_app/lib/models/order.dart
// Untuk extension string, opsional

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
    return name.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (match) => '_${match.group(0)!}',
    ).toUpperCase();
  }
}

class Order {
  final String id;
  final String customerName;
  final String productName;
  final double totalPrice;
  final OrderStatus status; // Gunakan enum OrderStatus
  final DateTime orderDate;
  late final DateTime lastUpdated;
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
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}