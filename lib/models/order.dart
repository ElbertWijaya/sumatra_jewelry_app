import 'package:flutter/foundation.dart';

/// Enum Status Pesanan sesuai alur kerja multi-divisi
enum OrderWorkflowStatus {
  pending, // Baru dibuat oleh sales, menunggu desain
  designing, // Sedang didesain oleh designer
  waiting_casting, // Menunggu proses cor setelah desain
  readyForCasting, // Siap untuk cor/casting
  casting, // Sedang dicor oleh tukang cor
  waiting_carving, // Menunggu proses carving setelah cor
  readyForCarving, // Siap untuk carving
  carving, // Sedang dikerjakan carver
  waiting_diamond_setting, // Menunggu proses diamond setting
  readyForStoneSetting, // Siap untuk pasang batu/berlian
  stoneSetting, // Sedang pasang batu/berlian
  waiting_finishing, // Menunggu proses finishing
  readyForFinishing, // Siap untuk finishing
  finishing, // Dalam proses finishing
  waiting_inventory, // Menunggu input inventaris
  readyForInventory, // Siap untuk inventory
  inventory, // Dalam proses inventory
  waiting_sales_completion, // Menunggu konfirmasi dari sales
  done, // Selesai, siap diambil customer
  cancelled, // Dibatalkan
  unknown, // Tidak diketahui
  debut, // <<< Tambahan status debut tanpa merusak fungsi lain
}

/// Extension parsing OrderWorkflowStatus dari string dan label
extension OrderWorkflowStatusX on OrderWorkflowStatus {
  static OrderWorkflowStatus fromString(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pending':
        return OrderWorkflowStatus.pending;
      case 'designing':
        return OrderWorkflowStatus.designing;
      case 'waiting_casting':
        return OrderWorkflowStatus.waiting_casting;
      case 'readyforcasting':
        return OrderWorkflowStatus.readyForCasting;
      case 'casting':
        return OrderWorkflowStatus.casting;
      case 'waiting_carving':
        return OrderWorkflowStatus.waiting_carving;
      case 'readyforcarving':
        return OrderWorkflowStatus.readyForCarving;
      case 'carving':
        return OrderWorkflowStatus.carving;
      case 'waiting_diamond_setting':
        return OrderWorkflowStatus.waiting_diamond_setting;
      case 'readyforstonesetting':
        return OrderWorkflowStatus.readyForStoneSetting;
      case 'stonesetting':
        return OrderWorkflowStatus.stoneSetting;
      case 'waiting_finishing':
        return OrderWorkflowStatus.waiting_finishing;
      case 'readyforfinishing':
        return OrderWorkflowStatus.readyForFinishing;
      case 'finishing':
        return OrderWorkflowStatus.finishing;
      case 'waiting_inventory':
        return OrderWorkflowStatus.waiting_inventory;
      case 'readyforinventory':
        return OrderWorkflowStatus.readyForInventory;
      case 'inventory':
        return OrderWorkflowStatus.inventory;
      case 'waiting_sales_completion':
        return OrderWorkflowStatus.waiting_sales_completion;
      case 'done':
        return OrderWorkflowStatus.done;
      case 'cancelled':
        return OrderWorkflowStatus.cancelled;
      case 'debut':
        return OrderWorkflowStatus.debut;
      default:
        debugPrint('Status workflow pesanan tidak diketahui: $status');
        return OrderWorkflowStatus.unknown;
    }
  }

  /// Label status workflow dalam bahasa Indonesia
  String get label {
    switch (this) {
      case OrderWorkflowStatus.pending:
        return 'Menunggu Desain';
      case OrderWorkflowStatus.designing:
        return 'Proses Desain';
      case OrderWorkflowStatus.waiting_casting:
        return 'Menunggu Cor';
      case OrderWorkflowStatus.readyForCasting:
        return 'Siap Cor';
      case OrderWorkflowStatus.casting:
        return 'Proses Cor';
      case OrderWorkflowStatus.waiting_carving:
        return 'Menunggu Carver';
      case OrderWorkflowStatus.readyForCarving:
        return 'Siap Ukir';
      case OrderWorkflowStatus.carving:
        return 'Proses Ukir';
      case OrderWorkflowStatus.waiting_diamond_setting:
        return 'Menunggu Diamond Setting';
      case OrderWorkflowStatus.readyForStoneSetting:
        return 'Siap Pasang Batu';
      case OrderWorkflowStatus.stoneSetting:
        return 'Proses Pasang Batu';
      case OrderWorkflowStatus.waiting_finishing:
        return 'Menunggu Finishing';
      case OrderWorkflowStatus.readyForFinishing:
        return 'Siap Finishing';
      case OrderWorkflowStatus.finishing:
        return 'Proses Finishing';
      case OrderWorkflowStatus.waiting_inventory:
        return 'Menunggu Inventaris';
      case OrderWorkflowStatus.readyForInventory:
        return 'Siap Inventory';
      case OrderWorkflowStatus.inventory:
        return 'Input Inventaris';
      case OrderWorkflowStatus.waiting_sales_completion:
        return 'Menunggu Konfirmasi Sales';
      case OrderWorkflowStatus.done:
        return 'Selesai';
      case OrderWorkflowStatus.cancelled:
        return 'Batal';
      case OrderWorkflowStatus.debut:
        return 'Debut';
      case OrderWorkflowStatus.unknown:
      default:
        return 'Tidak Diketahui';
    }
  }
}

/// Model data pesanan (Order) terhubung workflow multi-divisi
class Order {
  final List<String>? imagePaths; //Gambar
  final String id;
  final String customerName; // Nama Pelanggan (wajib)
  final String customerContact; // Nomor Telepon (wajib)
  final String address; // Alamat (wajib)
  final String jewelryType; // Jenis Perhiasan (wajib)

  // Tambahan: Gold Color & Gold Type
  final String? goldColor; // Warna Emas
  final String? goldType; // Jenis Emas

  // Opsional
  final String? stoneType; // Jenis Batu
  final String? stoneSize; // Ukuran Batu (format: 'xx x yy')
  final String? ringSize; // Ukuran Cincin
  final DateTime? readyDate; // Tanggal Siap
  final DateTime? pickupDate; // Tanggal Ambil
  final double? goldPricePerGram; // Harga Emas per Gram
  final double? finalPrice; // Harga Akhir
  final String? notes; // Catatan tambahan

  final OrderWorkflowStatus workflowStatus; // Status workflow utama

  // Assignment per divisi (opsional, bisa digunakan untuk tracking PIC per divisi)
  final String? assignedDesigner;
  final String? assignedCaster;
  final String? assignedCarver;
  final String? assignedDiamondSetter;
  final String? assignedFinisher;
  final String? assignedInventory;

  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    this.imagePaths,
    required this.id,
    required this.customerName,
    required this.customerContact,
    required this.address,
    required this.jewelryType,
    this.goldColor, // ADD
    this.goldType, // ADD
    this.stoneType,
    this.stoneSize,
    this.ringSize,
    this.readyDate,
    this.pickupDate,
    this.goldPricePerGram,
    this.finalPrice,
    this.notes,
    this.workflowStatus = OrderWorkflowStatus.pending,
    this.assignedDesigner,
    this.assignedCaster,
    this.assignedCarver,
    this.assignedDiamondSetter,
    this.assignedFinisher,
    this.assignedInventory,
    DateTime? createdAt,
    this.updatedAt,
  }) : assert(customerName.isNotEmpty, 'Nama pelanggan wajib diisi'),
       assert(customerContact.isNotEmpty, 'Nomor telepon wajib diisi'),
       assert(address.isNotEmpty, 'Alamat wajib diisi'),
       assert(jewelryType.isNotEmpty, 'Jenis perhiasan wajib diisi'),
       createdAt = createdAt ?? DateTime.now();

  Order copyWith({
    List<String>? imagePaths,
    String? id,
    String? customerName,
    String? customerContact,
    String? address,
    String? jewelryType,
    String? goldColor, // ADD
    String? goldType, // ADD
    String? stoneType,
    String? stoneSize,
    String? ringSize,
    DateTime? readyDate,
    DateTime? pickupDate,
    double? goldPricePerGram,
    double? finalPrice,
    String? notes,
    OrderWorkflowStatus? workflowStatus,
    String? assignedDesigner,
    String? assignedCaster,
    String? assignedCarver,
    String? assignedDiamondSetter,
    String? assignedFinisher,
    String? assignedInventory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      imagePaths: imagePaths ?? this.imagePaths,
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerContact: customerContact ?? this.customerContact,
      address: address ?? this.address,
      jewelryType: jewelryType ?? this.jewelryType,
      goldColor: goldColor ?? this.goldColor, // ADD
      goldType: goldType ?? this.goldType, // ADD
      stoneType: stoneType ?? this.stoneType,
      stoneSize: stoneSize ?? this.stoneSize,
      ringSize: ringSize ?? this.ringSize,
      readyDate: readyDate ?? this.readyDate,
      pickupDate: pickupDate ?? this.pickupDate,
      goldPricePerGram: goldPricePerGram ?? this.goldPricePerGram,
      finalPrice: finalPrice ?? this.finalPrice,
      notes: notes ?? this.notes,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      assignedDesigner: assignedDesigner ?? this.assignedDesigner,
      assignedCaster: assignedCaster ?? this.assignedCaster,
      assignedCarver: assignedCarver ?? this.assignedCarver,
      assignedDiamondSetter:
          assignedDiamondSetter ?? this.assignedDiamondSetter,
      assignedFinisher: assignedFinisher ?? this.assignedFinisher,
      assignedInventory: assignedInventory ?? this.assignedInventory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      imagePaths:
          (json['imagePaths'] as List?)?.map((e) => e as String).toList(),
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerContact: json['customerContact'] as String,
      address: json['address'] as String,
      jewelryType: json['jewelryType'] as String,
      goldColor: json['goldColor'] as String?, // ADD
      goldType: json['goldType'] as String?, // ADD
      stoneType: json['stoneType'] as String?,
      stoneSize: json['stoneSize'] as String?,
      ringSize: json['ringSize'] as String?,
      readyDate:
          json['readyDate'] != null
              ? DateTime.tryParse(json['readyDate'])
              : null,
      pickupDate:
          json['pickupDate'] != null
              ? DateTime.tryParse(json['pickupDate'])
              : null,
      goldPricePerGram: (json['goldPricePerGram'] as num?)?.toDouble(),
      finalPrice: (json['finalPrice'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      workflowStatus: OrderWorkflowStatusX.fromString(
        json['workflowStatus'] as String?,
      ),
      assignedDesigner: json['assignedDesigner'] as String?,
      assignedCaster: json['assignedCaster'] as String?,
      assignedCarver: json['assignedCarver'] as String?,
      assignedDiamondSetter: json['assignedDiamondSetter'] as String?,
      assignedFinisher: json['assignedFinisher'] as String?,
      assignedInventory: json['assignedInventory'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'imagePaths': imagePaths,
    'id': id,
    'customerName': customerName,
    'customerContact': customerContact,
    'address': address,
    'jewelryType': jewelryType,
    'goldColor': goldColor, // ADD
    'goldType': goldType, // ADD
    'stoneType': stoneType,
    'stoneSize': stoneSize,
    'ringSize': ringSize,
    'readyDate': readyDate?.toIso8601String(),
    'pickupDate': pickupDate?.toIso8601String(),
    'goldPricePerGram': goldPricePerGram,
    'finalPrice': finalPrice,
    'notes': notes,
    'workflowStatus': workflowStatus.name,
    'assignedDesigner': assignedDesigner,
    'assignedCaster': assignedCaster,
    'assignedCarver': assignedCarver,
    'assignedDiamondSetter': assignedDiamondSetter,
    'assignedFinisher': assignedFinisher,
    'assignedInventory': assignedInventory,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}