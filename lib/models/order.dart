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

  // Nullable (BOLEH NULL)
  final String? goldColor;
  final String? goldType;
  final String? stoneType;
  final String? stoneSize;
  final String? ringSize;
  final DateTime? readyDate;
  final DateTime? pickupDate;
  final double? goldPricePerGram;
  final double? finalPrice;
  final double? dp;
  final double? sisaLunas;
  final String? notes;
  final DateTime? updatedAt;
  final List<String>? imagePaths;
  final OrderWorkflowStatus workflowStatus;

  // Checklist tiap pekerja (boleh null)
  final List<String>? designerWorkChecklist;
  final List<String>? castingWorkChecklist;
  final List<String>? carvingWorkChecklist;
  final List<String>? diamondSettingWorkChecklist;
  final List<String>? finishingWorkChecklist;
  final List<String>? inventoryWorkChecklist;

  Order({
    required this.id,
    required this.customerName,
    required this.customerContact,
    required this.address,
    required this.jewelryType,
    required this.createdAt,
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
    this.updatedAt,
    this.imagePaths,
    this.workflowStatus = OrderWorkflowStatus.unknown,
    this.designerWorkChecklist,
    this.castingWorkChecklist,
    this.carvingWorkChecklist,
    this.diamondSettingWorkChecklist,
    this.finishingWorkChecklist,
    this.inventoryWorkChecklist,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    List<String>? parseChecklist(dynamic val) {
      if (val == null) return null;
      if (val is List) return List<String>.from(val);
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) return List<String>.from(decoded);
        } catch (_) {}
      }
      return null;
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

      goldColor: map['gold_color']?.toString(),
      goldType: map['gold_type']?.toString(),
      stoneType: map['stone_type']?.toString(),
      stoneSize: map['stone_size']?.toString(),
      ringSize: map['ring_size']?.toString(),
      readyDate: map['ready_date'] != null && map['ready_date'] != ''
          ? DateTime.tryParse(map['ready_date'])
          : null,
      pickupDate: map['pickup_date'] != null && map['pickup_date'] != ''
          ? DateTime.tryParse(map['pickup_date'])
          : null,
      goldPricePerGram: map['gold_price_per_gram'] != null
          ? double.tryParse(map['gold_price_per_gram'].toString())
          : null,
      finalPrice: map['final_price'] != null
          ? double.tryParse(map['final_price'].toString())
          : null,
      dp: map['dp'] != null
          ? double.tryParse(map['dp'].toString())
          : null,
      sisaLunas: map['sisa_lunas'] != null
          ? double.tryParse(map['sisa_lunas'].toString())
          : null,
      notes: map['notes']?.toString(),
      updatedAt: map['updated_at'] != null && map['updated_at'] != ''
          ? DateTime.tryParse(map['updated_at'])
          : null,
      imagePaths: map['imagePaths'] is List
          ? List<String>.from(map['imagePaths'])
          : (map['imagePaths'] is String && map['imagePaths'] != null && map['imagePaths'] != ''
              ? List<String>.from(jsonDecode(map['imagePaths']))
              : null),
      workflowStatus: OrderWorkflowStatusX.fromString(map['workflow_status']),
      designerWorkChecklist: parseChecklist(map['designerWorkChecklist']),
      castingWorkChecklist: parseChecklist(map['castingWorkChecklist']),
      carvingWorkChecklist: parseChecklist(map['carvingWorkChecklist']),
      diamondSettingWorkChecklist: parseChecklist(map['diamondSettingWorkChecklist']),
      finishingWorkChecklist: parseChecklist(map['finishingWorkChecklist']),
      inventoryWorkChecklist: parseChecklist(map['inventoryWorkChecklist']),
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
    );
  }
}