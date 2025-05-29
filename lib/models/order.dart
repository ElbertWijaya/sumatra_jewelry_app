import 'dart:convert';

enum OrderWorkflowStatus {
  waitingSalesCheck,
  waitingDesigner,
  designing,
  waitingCasting,
  casting,
  waitingCarving,
  carving,
  waitingDiamondSetting,
  stoneSetting,
  waitingFinishing,
  finishing,
  waitingInventory,
  inventory,
  waitingSalesCompletion,
  done,
  cancelled,
  unknown,
}

extension OrderWorkflowStatusX on OrderWorkflowStatus {
  static OrderWorkflowStatus fromString(String? value) {
    switch (value) {
      case 'waiting_sales_check':
        return OrderWorkflowStatus.waitingSalesCheck;
      case 'waiting_designer':
        return OrderWorkflowStatus.waitingDesigner;
      case 'designing':
        return OrderWorkflowStatus.designing;
      case 'waiting_casting':
        return OrderWorkflowStatus.waitingCasting;
      case 'casting':
        return OrderWorkflowStatus.casting;
      case 'waiting_carving':
        return OrderWorkflowStatus.waitingCarving;
      case 'carving':
        return OrderWorkflowStatus.carving;
      case 'waiting_diamond_setting':
        return OrderWorkflowStatus.waitingDiamondSetting;
      case 'stone_setting':
        return OrderWorkflowStatus.stoneSetting;
      case 'waiting_finishing':
        return OrderWorkflowStatus.waitingFinishing;
      case 'finishing':
        return OrderWorkflowStatus.finishing;
      case 'waiting_inventory':
        return OrderWorkflowStatus.waitingInventory;
      case 'inventory':
        return OrderWorkflowStatus.inventory;
      case 'waiting_sales_completion':
        return OrderWorkflowStatus.waitingSalesCompletion;
      case 'done':
        return OrderWorkflowStatus.done;
      case 'cancelled':
        return OrderWorkflowStatus.cancelled;
      default:
        return OrderWorkflowStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case OrderWorkflowStatus.waitingSalesCheck:
        return 'Waiting Sales Check';
      case OrderWorkflowStatus.waitingDesigner:
        return 'Waiting Designer';
      case OrderWorkflowStatus.designing:
        return 'Designing';
      case OrderWorkflowStatus.waitingCasting:
        return 'Waiting Casting';
      case OrderWorkflowStatus.casting:
        return 'Casting';
      case OrderWorkflowStatus.waitingCarving:
        return 'Waiting Carving';
      case OrderWorkflowStatus.carving:
        return 'Carving';
      case OrderWorkflowStatus.waitingDiamondSetting:
        return 'Waiting Diamond Setting';
      case OrderWorkflowStatus.stoneSetting:
        return 'Stone Setting';
      case OrderWorkflowStatus.waitingFinishing:
        return 'Waiting Finishing';
      case OrderWorkflowStatus.finishing:
        return 'Finishing';
      case OrderWorkflowStatus.waitingInventory:
        return 'Waiting Inventory';
      case OrderWorkflowStatus.inventory:
        return 'Inventory';
      case OrderWorkflowStatus.waitingSalesCompletion:
        return 'Waiting Sales Completion';
      case OrderWorkflowStatus.done:
        return 'Selesai';
      case OrderWorkflowStatus.cancelled:
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }
}

class Order {
  // Non-nullable (WAJIB)
  final String id;
  final String customerName;
  final String customerContact;
  final String address;
  final String jewelryType;
  final DateTime createdAt;

  // Non-nullable dengan default value
  final String goldColor;
  final String goldType;
  final String stoneType;
  final String stoneSize;
  final String ringSize;
  final DateTime? readyDate;
  final DateTime? pickupDate;
  final double goldPricePerGram;
  final double finalPrice;
  final double dp;
  final double sisaLunas;
  final String notes;
  final DateTime? updatedAt;
  final List<String> imagePaths;
  final OrderWorkflowStatus workflowStatus;

  // Checklist tiap pekerja (boleh kosong, tidak null)
  final List<String> designerWorkChecklist;
  final List<String> castingWorkChecklist;
  final List<String> carvingWorkChecklist;
  final List<String> diamondSettingWorkChecklist;
  final List<String> finishingWorkChecklist;
  final List<String> inventoryWorkChecklist;

  // Tambahan untuk penanganan error
  final String inventoryProductCode;
  final String inventoryProductName;
  final String inventoryShelfLocation;
  final String inventoryNotes;

  Order({
    required this.id,
    required this.customerName,
    required this.customerContact,
    required this.address,
    required this.jewelryType,
    required this.createdAt,
    this.goldColor = '',
    this.goldType = '',
    this.stoneType = '',
    this.stoneSize = '',
    this.ringSize = '',
    this.readyDate,
    this.pickupDate,
    this.goldPricePerGram = 0,
    this.finalPrice = 0,
    this.dp = 0,
    this.sisaLunas = 0,
    this.notes = '',
    this.updatedAt,
    List<String>? imagePaths,
    this.workflowStatus = OrderWorkflowStatus.unknown,
    List<String>? designerWorkChecklist,
    List<String>? castingWorkChecklist,
    List<String>? carvingWorkChecklist,
    List<String>? diamondSettingWorkChecklist,
    List<String>? finishingWorkChecklist,
    List<String>? inventoryWorkChecklist,
    this.inventoryProductCode = '',
    this.inventoryProductName = '',
    this.inventoryShelfLocation = '',
    this.inventoryNotes = '',
  })  : imagePaths = imagePaths ?? const [],
        designerWorkChecklist = designerWorkChecklist ?? const [],
        castingWorkChecklist = castingWorkChecklist ?? const [],
        carvingWorkChecklist = carvingWorkChecklist ?? const [],
        diamondSettingWorkChecklist = diamondSettingWorkChecklist ?? const [],
        finishingWorkChecklist = finishingWorkChecklist ?? const [],
        inventoryWorkChecklist = inventoryWorkChecklist ?? const [];

  factory Order.fromMap(Map<String, dynamic> map) {
    List<String> parseChecklist(dynamic val) {
      if (val == null) return [];
      if (val is List) return List<String>.from(val);
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) return List<String>.from(decoded);
        } catch (_) {}
      }
      return [];
    }

    List<String> parseImagePaths(dynamic val) {
      if (val == null) return [];
      if (val is List) return List<String>.from(val);
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) return List<String>.from(decoded);
        } catch (_) {}
      }
      return [];
    }

    return Order(
      id: map['id']?.toString() ?? '',
      customerName: map['customer_name']?.toString() ?? '',
      customerContact: map['customer_contact']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      jewelryType: map['jewelry_type']?.toString() ?? '',
      createdAt: map['created_at'] != null && map['created_at'] != ''
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      goldColor: map['gold_color']?.toString() ?? '',
      goldType: map['gold_type']?.toString() ?? '',
      stoneType: map['stone_type']?.toString() ?? '',
      stoneSize: map['stone_size']?.toString() ?? '',
      ringSize: map['ring_size']?.toString() ?? '',
      readyDate: map['ready_date'] != null && map['ready_date'] != ''
          ? DateTime.tryParse(map['ready_date'])
          : null,
      pickupDate: map['pickup_date'] != null && map['pickup_date'] != ''
          ? DateTime.tryParse(map['pickup_date'])
          : null,
      goldPricePerGram: map['gold_price_per_gram'] != null
          ? double.tryParse(map['gold_price_per_gram'].toString()) ?? 0
          : 0,
      finalPrice: map['final_price'] != null
          ? double.tryParse(map['final_price'].toString()) ?? 0
          : 0,
      dp: map['dp'] != null
          ? double.tryParse(map['dp'].toString()) ?? 0
          : 0,
      sisaLunas: map['sisa_lunas'] != null
          ? double.tryParse(map['sisa_lunas'].toString()) ?? 0
          : 0,
      notes: map['notes']?.toString() ?? '',
      updatedAt: map['updated_at'] != null && map['updated_at'] != ''
          ? DateTime.tryParse(map['updated_at'])
          : null,
      imagePaths: parseImagePaths(map['imagePaths']),
      workflowStatus: OrderWorkflowStatusX.fromString(map['workflow_status']),
      designerWorkChecklist: parseChecklist(map['designerWorkChecklist']),
      castingWorkChecklist: parseChecklist(map['castingWorkChecklist']),
      carvingWorkChecklist: parseChecklist(map['carvingWorkChecklist']),
      diamondSettingWorkChecklist: parseChecklist(map['diamondSettingWorkChecklist']),
      finishingWorkChecklist: parseChecklist(map['finishingWorkChecklist']),
      inventoryWorkChecklist: parseChecklist(map['inventoryWorkChecklist']),
      inventoryProductCode: map['inventoryProductCode']?.toString() ?? '',
      inventoryProductName: map['inventoryProductName']?.toString() ?? '',
      inventoryShelfLocation: map['inventoryShelfLocation']?.toString() ?? '',
      inventoryNotes: map['inventoryNotes']?.toString() ?? '',
    );
  }

  Order copyWith({
    String? id,
    String? customerName,
    String? customerContact,
    String? address,
    String? jewelryType,
    DateTime? createdAt,
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
    DateTime? updatedAt,
    List<String>? imagePaths,
    OrderWorkflowStatus? workflowStatus,
    List<String>? designerWorkChecklist,
    List<String>? castingWorkChecklist,
    List<String>? carvingWorkChecklist,
    List<String>? diamondSettingWorkChecklist,
    List<String>? finishingWorkChecklist,
    List<String>? inventoryWorkChecklist,
    String? inventoryProductCode,
    String? inventoryProductName,
    String? inventoryShelfLocation,
    String? inventoryNotes,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerContact: customerContact ?? this.customerContact,
      address: address ?? this.address,
      jewelryType: jewelryType ?? this.jewelryType,
      createdAt: createdAt ?? this.createdAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
      imagePaths: imagePaths ?? this.imagePaths,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      designerWorkChecklist: designerWorkChecklist ?? this.designerWorkChecklist,
      castingWorkChecklist: castingWorkChecklist ?? this.castingWorkChecklist,
      carvingWorkChecklist: carvingWorkChecklist ?? this.carvingWorkChecklist,
      diamondSettingWorkChecklist: diamondSettingWorkChecklist ?? this.diamondSettingWorkChecklist,
      finishingWorkChecklist: finishingWorkChecklist ?? this.finishingWorkChecklist,
      inventoryWorkChecklist: inventoryWorkChecklist ?? this.inventoryWorkChecklist,
      inventoryProductCode: inventoryProductCode ?? this.inventoryProductCode,
      inventoryProductName: inventoryProductName ?? this.inventoryProductName,
      inventoryShelfLocation: inventoryShelfLocation ?? this.inventoryShelfLocation,
      inventoryNotes: inventoryNotes ?? this.inventoryNotes,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return List<String>.from(val);
      return [];
    }

    return Order(
      id: json['id'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerContact: json['customerContact'] as String? ?? '',
      address: json['address'] as String? ?? '',
      jewelryType: json['jewelryType'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      goldColor: json['goldColor'] as String? ?? '',
      goldType: json['goldType'] as String? ?? '',
      stoneType: json['stoneType'] as String? ?? '',
      stoneSize: json['stoneSize'] as String? ?? '',
      ringSize: json['ringSize'] as String? ?? '',
      readyDate: json['readyDate'] != null
          ? DateTime.tryParse(json['readyDate'] as String)
          : null,
      pickupDate: json['pickupDate'] != null
          ? DateTime.tryParse(json['pickupDate'] as String)
          : null,
      goldPricePerGram: (json['goldPricePerGram'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0,
      dp: (json['dp'] as num?)?.toDouble() ?? 0,
      sisaLunas: (json['sisaLunas'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      imagePaths: parseList(json['imagePaths']),
      workflowStatus: OrderWorkflowStatusX.fromString(json['workflowStatus'] as String?),
      designerWorkChecklist: parseList(json['designerWorkChecklist']),
      castingWorkChecklist: parseList(json['castingWorkChecklist']),
      carvingWorkChecklist: parseList(json['carvingWorkChecklist']),
      diamondSettingWorkChecklist: parseList(json['diamondSettingWorkChecklist']),
      finishingWorkChecklist: parseList(json['finishingWorkChecklist']),
      inventoryWorkChecklist: parseList(json['inventoryWorkChecklist']),
      inventoryProductCode: json['inventoryProductCode'] as String? ?? '',
      inventoryProductName: json['inventoryProductName'] as String? ?? '',
      inventoryShelfLocation: json['inventoryShelfLocation'] as String? ?? '',
      inventoryNotes: json['inventoryNotes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerContact': customerContact,
      'address': address,
      'jewelryType': jewelryType,
      'createdAt': createdAt.toIso8601String(),
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
      'updatedAt': updatedAt?.toIso8601String(),
      'imagePaths': imagePaths,
      'workflowStatus': workflowStatus.name,
      'designerWorkChecklist': designerWorkChecklist,
      'castingWorkChecklist': castingWorkChecklist,
      'carvingWorkChecklist': carvingWorkChecklist,
      'diamondSettingWorkChecklist': diamondSettingWorkChecklist,
      'finishingWorkChecklist': finishingWorkChecklist,
      'inventoryWorkChecklist': inventoryWorkChecklist,
      'inventoryProductCode': inventoryProductCode,
      'inventoryProductName': inventoryProductName,
      'inventoryShelfLocation': inventoryShelfLocation,
      'inventoryNotes': inventoryNotes,
    };
  }
}