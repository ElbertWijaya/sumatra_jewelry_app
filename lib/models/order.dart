import 'dart:convert'; // Tetap diperlukan jika Anda menggunakan JSON encoding/decoding

class Order {
  final int id;
  final String customerName;
  final String phoneNumber;
  final String address;
  final String productName;
  final String productDescription;
  final double estimatedPrice;
  final String status;
  final DateTime orderDate;
  // final DateTime? completionDate; // Dihapus/diabaikan jika menggunakan completionDate per tahap yang spesifik
  DateTime? designCompletionDate;
  DateTime? corCompletionDate;
  DateTime? carvingCompletionDate;
  DateTime? diamondSettingCompletionDate;
  DateTime? finishingCompletionDate;
  final String? currentWorkerRole;
  final String? diamondSize;
  final String? ringSize;
  final DateTime? estimatedCompletionDate;
  final DateTime? pickupDate;
  final double? goldPricePerGram;
  final double? finalProductPrice;
  final String? goldType;
  final List<String>? referenceImagePaths;
  final DateTime? lastUpdate;

  Order({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    required this.productName,
    required this.productDescription,
    required this.estimatedPrice,
    required this.status,
    required this.orderDate,
    // this.completionDate, // Hapus dari konstruktor jika tidak digunakan
    this.designCompletionDate,
    this.corCompletionDate,
    this.carvingCompletionDate,
    this.diamondSettingCompletionDate,
    this.finishingCompletionDate,
    this.currentWorkerRole,
    this.diamondSize,
    this.ringSize,
    this.estimatedCompletionDate,
    this.pickupDate,
    this.goldPricePerGram,
    this.finalProductPrice,
    this.goldType,
    this.referenceImagePaths,
    this.lastUpdate,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int, // Pastikan ini di-cast ke int
      customerName: map['customerName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      address: map['address'] as String,
      productName: map['productName'] as String,
      productDescription: map['productDescription'] as String,
      estimatedPrice:
          (map['estimatedPrice'] is int
                  ? (map['estimatedPrice'] as int).toDouble()
                  : map['estimatedPrice'])
              as double,
      status: map['status'] as String,
      orderDate: DateTime.parse(map['orderDate'] as String),
      // completionDate: // Hapus dari fromMap jika tidak digunakan
      //     map['completionDate'] != null
      //         ? DateTime.parse(map['completionDate'] as String)
      //         : null,
      // Penanganan completionDate per tahap
      designCompletionDate:
          map['designCompletionDate'] != null
              ? DateTime.parse(map['designCompletionDate'] as String)
              : null,
      corCompletionDate:
          map['corCompletionDate'] != null
              ? DateTime.parse(map['corCompletionDate'] as String)
              : null,
      carvingCompletionDate:
          map['carvingCompletionDate'] != null
              ? DateTime.parse(map['carvingCompletionDate'] as String)
              : null,
      diamondSettingCompletionDate:
          map['diamondSettingCompletionDate'] != null
              ? DateTime.parse(map['diamondSettingCompletionDate'] as String)
              : null,
      finishingCompletionDate:
          map['finishingCompletionDate'] != null
              ? DateTime.parse(map['finishingCompletionDate'] as String)
              : null,

      currentWorkerRole: map['currentWorkerRole'] as String?,
      diamondSize: map['diamondSize'] as String?,
      ringSize: map['ringSize'] as String?,
      estimatedCompletionDate:
          map['estimatedCompletionDate'] != null
              ? DateTime.parse(map['estimatedCompletionDate'] as String)
              : null,
      pickupDate:
          map['pickupDate'] != null
              ? DateTime.parse(map['pickupDate'] as String)
              : null,
      goldPricePerGram:
          (map['goldPricePerGram'] is int
                  ? (map['goldPricePerGram'] as int).toDouble()
                  : map['goldPricePerGram'])
              as double?,
      finalProductPrice:
          (map['finalProductPrice'] is int
                  ? (map['finalProductPrice'] as int).toDouble()
                  : map['finalProductPrice'])
              as double?,
      goldType: map['goldType'] as String?,
      // Perhatikan penanganan List<String> dari String yang dipisahkan koma
      referenceImagePaths: (map['referenceImagePaths'] as String?)?.split(','),
      lastUpdate:
          map['lastUpdate'] != null
              ? DateTime.parse(map['lastUpdate'] as String)
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'address': address,
      'productName': productName,
      'productDescription': productDescription,
      'estimatedPrice': estimatedPrice,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      // 'completionDate': completionDate?.toIso8601String(), // Hapus dari toMap jika tidak digunakan
      // Penanganan completionDate per tahap
      'designCompletionDate': designCompletionDate?.toIso8601String(),
      'corCompletionDate': corCompletionDate?.toIso8601String(),
      'carvingCompletionDate': carvingCompletionDate?.toIso8601String(),
      'diamondSettingCompletionDate':
          diamondSettingCompletionDate?.toIso8601String(),
      'finishingCompletionDate': finishingCompletionDate?.toIso8601String(),

      'currentWorkerRole': currentWorkerRole,
      'diamondSize': diamondSize,
      'ringSize': ringSize,
      'estimatedCompletionDate': estimatedCompletionDate?.toIso8601String(),
      'pickupDate': pickupDate?.toIso8601String(),
      'goldPricePerGram': goldPricePerGram,
      'finalProductPrice': finalProductPrice,
      'goldType': goldType,
      // Perhatikan penanganan List<String> ke String yang dipisahkan koma
      'referenceImagePaths': referenceImagePaths?.join(','),
      'lastUpdate': lastUpdate?.toIso8601String(),
    };
  }

  /// Metode copyWith ini memungkinkan Anda membuat salinan objek Order dengan
  /// nilai properti yang diubah tanpa mengubah objek asli.
  Order copyWith({
    int? id,
    String? customerName,
    String? phoneNumber,
    String? address,
    String? productName,
    String? productDescription,
    double? estimatedPrice,
    String? status,
    DateTime? orderDate,
    String? currentWorkerRole,
    DateTime? designCompletionDate, // Ditambahkan
    DateTime? corCompletionDate, // Ditambahkan
    DateTime? carvingCompletionDate, // Ditambahkan
    DateTime? diamondSettingCompletionDate, // Ditambahkan
    DateTime? finishingCompletionDate, // Ditambahkan
    String? diamondSize,
    String? ringSize,
    DateTime? estimatedCompletionDate,
    DateTime? pickupDate,
    double? goldPricePerGram,
    double? finalProductPrice,
    String? goldType,
    List<String>? referenceImagePaths,
    DateTime? lastUpdate,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      currentWorkerRole: currentWorkerRole ?? this.currentWorkerRole,
      diamondSize: diamondSize ?? this.diamondSize,
      ringSize: ringSize ?? this.ringSize,
      estimatedCompletionDate:
          estimatedCompletionDate ?? this.estimatedCompletionDate,
      pickupDate: pickupDate ?? this.pickupDate,
      goldPricePerGram: goldPricePerGram ?? this.goldPricePerGram,
      finalProductPrice: finalProductPrice ?? this.finalProductPrice,
      goldType: goldType ?? this.goldType,
      referenceImagePaths: referenceImagePaths ?? this.referenceImagePaths,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      // Tambahkan completionDate per tahap
      designCompletionDate: designCompletionDate ?? this.designCompletionDate,
      corCompletionDate: corCompletionDate ?? this.corCompletionDate,
      carvingCompletionDate:
          carvingCompletionDate ?? this.carvingCompletionDate,
      diamondSettingCompletionDate:
          diamondSettingCompletionDate ?? this.diamondSettingCompletionDate,
      finishingCompletionDate:
          finishingCompletionDate ?? this.finishingCompletionDate,
    );
  }
}
