import 'package:flutter/foundation.dart';

/// Enum Status Pesanan sesuai alur kerja multi-divisi
enum OrderWorkflowStatus {
  waitingSalesCheck,
  waitingDesigner,
  pending,
  designing,
  waitingCasting,
  readyForCasting,
  casting,
  waitingCarving,
  readyForCarving,
  carving,
  waitingDiamondSetting,
  readyForStoneSetting,
  stoneSetting,
  waitingFinishing,
  readyForFinishing,
  finishing,
  waitingInventory,
  readyForInventory,
  inventory,
  waitingSalesCompletion,
  done,
  cancelled,
  unknown,
  debut,
}

/// Extension parsing OrderWorkflowStatus dari string dan label
extension OrderWorkflowStatusX on OrderWorkflowStatus {
  static OrderWorkflowStatus fromString(String? status) {
    switch ((status ?? '').replaceAll('_', '').toLowerCase()) {
      case 'waitingsalescheck':
        return OrderWorkflowStatus.waitingSalesCheck;
      case 'waitingdesigner':
        return OrderWorkflowStatus.waitingDesigner;
      case 'pending':
        return OrderWorkflowStatus.pending;
      case 'designing':
        return OrderWorkflowStatus.designing;
      case 'waitingcasting':
        return OrderWorkflowStatus.waitingCasting;
      case 'readyforcasting':
        return OrderWorkflowStatus.readyForCasting;
      case 'casting':
        return OrderWorkflowStatus.casting;
      case 'waitingcarving':
        return OrderWorkflowStatus.waitingCarving;
      case 'readyforcarving':
        return OrderWorkflowStatus.readyForCarving;
      case 'carving':
        return OrderWorkflowStatus.carving;
      case 'waitingdiamondsetting':
        return OrderWorkflowStatus.waitingDiamondSetting;
      case 'readyforstonesetting':
        return OrderWorkflowStatus.readyForStoneSetting;
      case 'stonesetting':
        return OrderWorkflowStatus.stoneSetting;
      case 'waitingfinishing':
        return OrderWorkflowStatus.waitingFinishing;
      case 'readyforfinishing':
        return OrderWorkflowStatus.readyForFinishing;
      case 'finishing':
        return OrderWorkflowStatus.finishing;
      case 'waitinginventory':
        return OrderWorkflowStatus.waitingInventory;
      case 'readyforinventory':
        return OrderWorkflowStatus.readyForInventory;
      case 'inventory':
        return OrderWorkflowStatus.inventory;
      case 'waitingsalescompletion':
        return OrderWorkflowStatus.waitingSalesCompletion;
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
      case OrderWorkflowStatus.waitingSalesCheck:
        return 'Cek & Submit Sales';
      case OrderWorkflowStatus.waitingDesigner:
        return 'Menunggu Designer';
      case OrderWorkflowStatus.pending:
        return 'Menunggu Desain';
      case OrderWorkflowStatus.designing:
        return 'Proses Desain';
      case OrderWorkflowStatus.waitingCasting:
        return 'Menunggu Cor';
      case OrderWorkflowStatus.readyForCasting:
        return 'Siap Cor';
      case OrderWorkflowStatus.casting:
        return 'Proses Cor';
      case OrderWorkflowStatus.waitingCarving:
        return 'Menunggu Carver';
      case OrderWorkflowStatus.readyForCarving:
        return 'Siap Ukir';
      case OrderWorkflowStatus.carving:
        return 'Proses Ukir';
      case OrderWorkflowStatus.waitingDiamondSetting:
        return 'Menunggu Diamond Setting';
      case OrderWorkflowStatus.readyForStoneSetting:
        return 'Siap Pasang Batu';
      case OrderWorkflowStatus.stoneSetting:
        return 'Proses Pasang Batu';
      case OrderWorkflowStatus.waitingFinishing:
        return 'Menunggu Finishing';
      case OrderWorkflowStatus.readyForFinishing:
        return 'Siap Finishing';
      case OrderWorkflowStatus.finishing:
        return 'Proses Finishing';
      case OrderWorkflowStatus.waitingInventory:
        return 'Menunggu Inventaris';
      case OrderWorkflowStatus.readyForInventory:
        return 'Siap Inventory';
      case OrderWorkflowStatus.inventory:
        return 'Input Inventaris';
      case OrderWorkflowStatus.waitingSalesCompletion:
        return 'Menunggu Konfirmasi Sales';
      case OrderWorkflowStatus.done:
        return 'Selesai';
      case OrderWorkflowStatus.cancelled:
        return 'Batal';
      case OrderWorkflowStatus.debut:
        return 'Debut';
      case OrderWorkflowStatus.unknown:
        return 'Tidak Diketahui';
    }
  }
}

/// Model data pesanan (Order) terhubung workflow multi-divisi
class Order {
  final List<String>? imagePaths;
  final String id;
  final String customerName;
  final String customerContact;
  final String address;
  final String jewelryType;
  final String? goldColor;
  final String? goldType;
  final String? stoneType;
  final String? stoneSize;
  final String? ringSize;
  final DateTime? readyDate;
  final DateTime? pickupDate;
  final double? goldPricePerGram;
  final double? finalPrice; // untuk harga barang/perkiraan
  final double? dp;
  final double? sisaLunas;
  final String? notes;
  final OrderWorkflowStatus workflowStatus;

  // Tambahan: Checklist kerja designer
  final List<String>? designerWorkChecklist;
  final List<String>? castingWorkChecklist;
  final List<String>? carvingWorkChecklist;
  final List<String>? stoneSettingWorkChecklist;
  final List<String>? finishingWorkChecklist;

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
    this.goldColor,
    this.goldType,
    this.stoneType,
    this.stoneSize,
    this.ringSize,
    this.readyDate,
    this.pickupDate,
    this.goldPricePerGram,
    this.finalPrice,
    this.dp,
    this.sisaLunas,
    this.notes,
    this.workflowStatus = OrderWorkflowStatus.pending,
    this.designerWorkChecklist,
    this.castingWorkChecklist,
    this.carvingWorkChecklist,
    this.stoneSettingWorkChecklist,
    this.finishingWorkChecklist,
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
    String? goldColor,
    String? goldType,
    String? stoneType,
    String? stoneSize,
    String? ringSize,
    DateTime? readyDate,
    DateTime? pickupDate,
    double? goldPricePerGram,
    double? finalPrice,
    double? dp,
    double? sisaLunas,
    String? notes,
    OrderWorkflowStatus? workflowStatus,
    List<String>? designerWorkChecklist,
    List<String>? castingWorkChecklist,
    List<String>? carvingWorkChecklist,
    List<String>? stoneSettingWorkChecklist,
    List<String>? finishingWorkChecklist,
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
      goldColor: goldColor ?? this.goldColor,
      goldType: goldType ?? this.goldType,
      stoneType: stoneType ?? this.stoneType,
      stoneSize: stoneSize ?? this.stoneSize,
      ringSize: ringSize ?? this.ringSize,
      readyDate: readyDate ?? this.readyDate,
      pickupDate: pickupDate ?? this.pickupDate,
      goldPricePerGram: goldPricePerGram ?? this.goldPricePerGram,
      finalPrice: finalPrice ?? this.finalPrice,
      dp: dp ?? this.dp,
      sisaLunas: sisaLunas ?? this.sisaLunas,
      notes: notes ?? this.notes,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      designerWorkChecklist:
          designerWorkChecklist ?? this.designerWorkChecklist,
      castingWorkChecklist: castingWorkChecklist ?? this.castingWorkChecklist,
      carvingWorkChecklist: carvingWorkChecklist ?? this.carvingWorkChecklist,
      stoneSettingWorkChecklist:
          stoneSettingWorkChecklist ?? this.stoneSettingWorkChecklist,
      finishingWorkChecklist:
          finishingWorkChecklist ?? this.finishingWorkChecklist,
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
      goldColor: json['goldColor'] as String?,
      goldType: json['goldType'] as String?,
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
      dp: (json['dp'] as num?)?.toDouble(),
      sisaLunas: (json['sisaLunas'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      workflowStatus: OrderWorkflowStatusX.fromString(
        json['workflowStatus'] as String?,
      ),
      designerWorkChecklist:
          (json['designerWorkChecklist'] as List?)
              ?.map((e) => e as String)
              .toList(),
      castingWorkChecklist:
          (json['castingWorkChecklist'] as List?)
              ?.map((e) => e as String)
              .toList(),
      carvingWorkChecklist:
          (json['carvingWorkChecklist'] as List?)
              ?.map((e) => e as String)
              .toList(),
      stoneSettingWorkChecklist:
          (json['stoneSettingWorkChecklist'] as List?)
              ?.map((e) => e as String)
              .toList(),
      finishingWorkChecklist:
          (json['finishingWorkChecklist'] as List?)
              ?.map((e) => e as String)
              .toList(),

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
    'goldColor': goldColor,
    'goldType': goldType,
    'stoneType': stoneType,
    'stoneSize': stoneSize,
    'ringSize': ringSize,
    'readyDate': readyDate?.toIso8601String(),
    'pickupDate': pickupDate?.toIso8601String(),
    'goldPricePerGram': goldPricePerGram,
    'finalPrice': finalPrice,
    'dp': dp,
    'sisaLunas': sisaLunas,
    'notes': notes,
    'workflowStatus': workflowStatus.name,
    'designerWorkChecklist': designerWorkChecklist,
    'castingWorkChecklist': castingWorkChecklist,
    'carvingWorkChecklist': carvingWorkChecklist,
    'stoneSettingWorkChecklist': stoneSettingWorkChecklist,
    'finishingWorkChecklist': finishingWorkChecklist,
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
