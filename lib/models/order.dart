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
}

extension OrderWorkflowStatusX on OrderWorkflowStatus {
  static OrderWorkflowStatus fromString(String? value) {
    switch (value) {
      case 'waiting_sales_check':
      case 'waitingSalesCheck':
        return OrderWorkflowStatus.waitingSalesCheck;
      case 'waiting_designer':
      case 'waitingDesigner':
        return OrderWorkflowStatus.waitingDesigner;
      case 'designing':
        return OrderWorkflowStatus.designing;
      case 'waiting_casting':
      case 'waitingCasting':
        return OrderWorkflowStatus.waitingCasting;
      case 'casting':
        return OrderWorkflowStatus.casting;
      case 'waiting_carving':
      case 'waitingCarving':
        return OrderWorkflowStatus.waitingCarving;
      case 'carving':
        return OrderWorkflowStatus.carving;
      case 'waiting_diamond_setting':
      case 'waitingDiamondSetting':
        return OrderWorkflowStatus.waitingDiamondSetting;
      case 'stone_setting':
      case 'stoneSetting':
        return OrderWorkflowStatus.stoneSetting;
      case 'waiting_finishing':
      case 'waitingFinishing':
        return OrderWorkflowStatus.waitingFinishing;
      case 'finishing':
        return OrderWorkflowStatus.finishing;
      case 'waiting_inventory':
      case 'waitingInventory':
        return OrderWorkflowStatus.waitingInventory;
      case 'inventory':
        return OrderWorkflowStatus.inventory;
      case 'waiting_sales_completion':
      case 'waitingSalesCompletion':
        return OrderWorkflowStatus.waitingSalesCompletion;
      case 'done':
        return OrderWorkflowStatus.done;
      case 'cancelled':
        return OrderWorkflowStatus.cancelled;
      default:
        return OrderWorkflowStatus.waitingSalesCheck; // Default case
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
        return 'Waiting Sales Check'; // Default case
    }
  }
}

class Order {
  // Non-nullable (WAJIB)
  final String ordersId;
  final String ordersCustomerName;
  final String ordersCustomerContact;
  final String ordersAddress;
  final String ordersJewelryType;
  final DateTime ordersCreatedAt;

  final String ordersGoldColor;
  final String ordersGoldType;
  final String ordersRingSize;
  final DateTime? ordersReadyDate;
  final DateTime? ordersPickupDate;
  final double ordersGoldPricePerGram;
  final double ordersFinalPrice;
  final double ordersDp;
  final double ordersSisaLunas;
  final String ordersNote;
  final DateTime? ordersUpdatedAt;
  final List<String> ordersImagePaths;
  final OrderWorkflowStatus ordersWorkflowStatus;
  final List<String> ordersDesignerWorkChecklist;
  final List<String> ordersCastingWorkChecklist;
  final List<String> ordersCarvingWorkChecklist;
  final List<String> ordersDiamondSettingWorkChecklist;
  final List<String> ordersFinishingWorkChecklist;

  // Data inventory (hanya yang perlu)
  final String? inventoryProductId;
  final String? inventoryJewelryType;
  final String? inventoryGoldColor;
  final String? inventoryGoldType;
  final List<Map<String, dynamic>>? inventoryStoneUsed;
  final List<String>? inventoryImagePaths;
  final double? inventoryItemsPrice;
  final String? inventoryRingSize;

  Order({
    required this.ordersId,
    required this.ordersCustomerName,
    required this.ordersCustomerContact,
    required this.ordersAddress,
    required this.ordersJewelryType,
    required this.ordersCreatedAt,
    this.ordersGoldColor = '',
    this.ordersGoldType = '',
    this.ordersRingSize = '',
    this.ordersReadyDate,
    this.ordersPickupDate,
    this.ordersGoldPricePerGram = 0,
    this.ordersFinalPrice = 0,
    this.ordersDp = 0,
    this.ordersSisaLunas = 0,
    this.ordersNote = '',
    this.ordersUpdatedAt,
    List<String>? ordersImagePaths,
    this.ordersWorkflowStatus = OrderWorkflowStatus.waitingSalesCheck,
    List<String>? ordersDesignerWorkChecklist,
    List<String>? ordersCastingWorkChecklist,
    List<String>? ordersCarvingWorkChecklist,
    List<String>? ordersDiamondSettingWorkChecklist,
    List<String>? ordersFinishingWorkChecklist,
    this.inventoryProductId,
    this.inventoryJewelryType,
    this.inventoryGoldColor,
    this.inventoryGoldType,
    this.inventoryStoneUsed,
    this.inventoryImagePaths,
    this.inventoryItemsPrice,
    this.inventoryRingSize,
  }) : ordersImagePaths = ordersImagePaths ?? const [],
       ordersDesignerWorkChecklist = ordersDesignerWorkChecklist ?? const [],
       ordersCastingWorkChecklist = ordersCastingWorkChecklist ?? const [],
       ordersCarvingWorkChecklist = ordersCarvingWorkChecklist ?? const [],
       ordersDiamondSettingWorkChecklist =
           ordersDiamondSettingWorkChecklist ?? const [],
       ordersFinishingWorkChecklist = ordersFinishingWorkChecklist ?? const [];

  factory Order.fromMap(Map<String, dynamic> map) {
    List<String> parseChecklist(dynamic val) {
      if (val == null) return [];
      if (val is List) return List<String>.from(val.map((e) => e.toString()));
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List)
            return List<String>.from(decoded.map((e) => e.toString()));
        } catch (_) {}
      }
      return [];
    }

    List<String> parseImagePaths(dynamic val) {
      if (val == null) return [];
      if (val is List) return List<String>.from(val.map((e) => e.toString()));
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List)
            return List<String>.from(decoded.map((e) => e.toString()));
        } catch (_) {}
      }
      return [];
    }

    return Order(
      ordersId: map['orders_id']?.toString() ?? '',
      ordersCustomerName: map['orders_customer_name']?.toString() ?? '',
      ordersCustomerContact: map['orders_customer_contact']?.toString() ?? '',
      ordersAddress: map['orders_address']?.toString() ?? '',
      ordersJewelryType: map['orders_jewelry_type']?.toString() ?? '',
      ordersCreatedAt:
          map['orders_created_at'] != null && map['orders_created_at'] != ''
              ? DateTime.parse(map['orders_created_at'])
              : DateTime.now(),
      ordersGoldColor: map['orders_gold_color']?.toString() ?? '',
      ordersGoldType: map['orders_gold_type']?.toString() ?? '',
      ordersRingSize: map['orders_ring_size']?.toString() ?? '',
      ordersReadyDate:
          map['orders_ready_date'] != null && map['orders_ready_date'] != ''
              ? DateTime.tryParse(map['orders_ready_date'])
              : null,
      ordersPickupDate:
          map['orders_pickup_date'] != null && map['orders_pickup_date'] != ''
              ? DateTime.tryParse(map['orders_pickup_date'])
              : null,
      ordersGoldPricePerGram:
          map['orders_gold_price_per_gram'] != null
              ? double.tryParse(map['orders_gold_price_per_gram'].toString()) ??
                  0
              : 0,
      ordersFinalPrice:
          map['orders_final_price'] != null
              ? double.tryParse(map['orders_final_price'].toString()) ?? 0
              : 0,
      ordersDp:
          map['orders_dp'] != null
              ? double.tryParse(map['orders_dp'].toString()) ?? 0
              : 0,
      ordersSisaLunas:
          map['orders_sisa_lunas'] != null
              ? double.tryParse(map['orders_sisa_lunas'].toString()) ?? 0
              : 0,
      ordersNote: map['orders_note']?.toString() ?? '',
      ordersUpdatedAt:
          map['orders_updated_at'] != null && map['orders_updated_at'] != ''
              ? DateTime.tryParse(map['orders_updated_at'])
              : null,
      ordersImagePaths: parseImagePaths(map['orders_imagePaths']),
      ordersWorkflowStatus: OrderWorkflowStatusX.fromString(
        map['orders_workflowStatus'],
      ),
      ordersDesignerWorkChecklist: parseChecklist(
        map['orders_designerWorkChecklist'],
      ),
      ordersCastingWorkChecklist: parseChecklist(
        map['orders_castingWorkChecklist'],
      ),
      ordersCarvingWorkChecklist: parseChecklist(
        map['orders_carvingWorkChecklist'],
      ),
      ordersDiamondSettingWorkChecklist: parseChecklist(
        map['orders_diamondSettingWorkChecklist'],
      ),
      ordersFinishingWorkChecklist: parseChecklist(
        map['orders_finishingWorkChecklist'],
      ),
      inventoryProductId: map['inventory_product_id']?.toString() ?? '',
      inventoryJewelryType: map['inventory_jewelry_type']?.toString() ?? '',
      inventoryGoldColor: map['inventory_gold_color']?.toString() ?? '',
      inventoryGoldType: map['inventory_gold_type']?.toString() ?? '',
      inventoryStoneUsed:
          map['inventory_stone_used'] != null
              ? List<Map<String, dynamic>>.from(
                map['inventory_stone_used'].map(
                  (e) => Map<String, dynamic>.from(e),
                ),
              )
              : null,
      inventoryImagePaths:
          map['inventory_imagePaths'] != null
              ? parseImagePaths(map['inventory_imagePaths'])
              : [],
      inventoryItemsPrice:
          map['inventory_items_price'] != null
              ? double.tryParse(map['inventory_items_price'].toString()) ?? 0
              : null,
      inventoryRingSize: map['inventory_ring_size']?.toString(),
    );
  }

  Order copyWith({
    String? ordersId,
    String? ordersCustomerName,
    String? ordersCustomerContact,
    String? ordersAddress,
    String? ordersJewelryType,
    DateTime? ordersCreatedAt,
    String? ordersGoldColor,
    String? ordersGoldType,
    String? ordersRingSize,
    DateTime? ordersReadyDate,
    DateTime? ordersPickupDate,
    double? ordersGoldPricePerGram,
    double? ordersFinalPrice,
    double? ordersDp,
    double? ordersSisaLunas,
    String? ordersNote,
    DateTime? ordersUpdatedAt,
    List<String>? ordersImagePaths,
    OrderWorkflowStatus? ordersWorkflowStatus,
    List<String>? ordersDesignerWorkChecklist,
    List<String>? ordersCastingWorkChecklist,
    List<String>? ordersCarvingWorkChecklist,
    List<String>? ordersDiamondSettingWorkChecklist,
    List<String>? ordersFinishingWorkChecklist,
    String? inventoryProductId,
    String? inventoryJewelryType,
    String? inventoryGoldColor,
    String? inventoryGoldType,
    List<Map<String, dynamic>>? inventoryStoneUsed,
    List<String>? inventoryImagePaths,
    double? inventoryItemsPrice,
    String? inventoryRingSize,
  }) {
    return Order(
      ordersId: ordersId ?? this.ordersId,
      ordersCustomerName: ordersCustomerName ?? this.ordersCustomerName,
      ordersCustomerContact:
          ordersCustomerContact ?? this.ordersCustomerContact,
      ordersAddress: ordersAddress ?? this.ordersAddress,
      ordersJewelryType: ordersJewelryType ?? this.ordersJewelryType,
      ordersCreatedAt: ordersCreatedAt ?? this.ordersCreatedAt,
      ordersGoldColor: ordersGoldColor ?? this.ordersGoldColor,
      ordersGoldType: ordersGoldType ?? this.ordersGoldType,
      ordersRingSize: ordersRingSize ?? this.ordersRingSize,
      ordersReadyDate: ordersReadyDate ?? this.ordersReadyDate,
      ordersPickupDate: ordersPickupDate ?? this.ordersPickupDate,
      ordersGoldPricePerGram:
          ordersGoldPricePerGram ?? this.ordersGoldPricePerGram,
      ordersFinalPrice: ordersFinalPrice ?? this.ordersFinalPrice,
      ordersDp: ordersDp ?? this.ordersDp,
      ordersSisaLunas: ordersSisaLunas ?? this.ordersSisaLunas,
      ordersNote: ordersNote ?? this.ordersNote,
      ordersUpdatedAt: ordersUpdatedAt ?? this.ordersUpdatedAt,
      ordersImagePaths: ordersImagePaths ?? this.ordersImagePaths,
      ordersWorkflowStatus: ordersWorkflowStatus ?? this.ordersWorkflowStatus,
      ordersDesignerWorkChecklist:
          ordersDesignerWorkChecklist ?? this.ordersDesignerWorkChecklist,
      ordersCastingWorkChecklist:
          ordersCastingWorkChecklist ?? this.ordersCastingWorkChecklist,
      ordersCarvingWorkChecklist:
          ordersCarvingWorkChecklist ?? this.ordersCarvingWorkChecklist,
      ordersDiamondSettingWorkChecklist:
          ordersDiamondSettingWorkChecklist ??
          this.ordersDiamondSettingWorkChecklist,
      ordersFinishingWorkChecklist:
          ordersFinishingWorkChecklist ?? this.ordersFinishingWorkChecklist,
      inventoryProductId: inventoryProductId ?? this.inventoryProductId,
      inventoryJewelryType: inventoryJewelryType ?? this.inventoryJewelryType,
      inventoryGoldColor: inventoryGoldColor ?? this.inventoryGoldColor,
      inventoryGoldType: inventoryGoldType ?? this.inventoryGoldType,
      inventoryStoneUsed: inventoryStoneUsed ?? this.inventoryStoneUsed,
      inventoryImagePaths: inventoryImagePaths ?? this.inventoryImagePaths,
      inventoryItemsPrice: inventoryItemsPrice ?? this.inventoryItemsPrice,
      inventoryRingSize: inventoryRingSize ?? this.inventoryRingSize,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    List<String> parseChecklist(dynamic val) {
      if (val == null) return [];
      if (val is List) return List<String>.from(val.map((e) => e.toString()));
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List)
            return List<String>.from(decoded.map((e) => e.toString()));
        } catch (_) {}
      }
      return [];
    }

    List<String> parseImagePaths(dynamic val) {
      if (val == null) return [];
      if (val is List) return List<String>.from(val.map((e) => e.toString()));
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List)
            return List<String>.from(decoded.map((e) => e.toString()));
        } catch (_) {}
      }
      return [];
    }

    return Order(
      ordersId: json['orders_id']?.toString() ?? '',
      ordersCustomerName: json['orders_customer_name']?.toString() ?? '',
      ordersCustomerContact: json['orders_customer_contact']?.toString() ?? '',
      ordersAddress: json['orders_address']?.toString() ?? '',
      ordersJewelryType: json['orders_jewelry_type']?.toString() ?? '',
      ordersCreatedAt:
          json['orders_created_at'] != null
              ? DateTime.parse(json['orders_created_at'].toString())
              : DateTime.now(),
      ordersGoldColor: json['orders_gold_color']?.toString() ?? '',
      ordersGoldType: json['orders_gold_type']?.toString() ?? '',
      ordersRingSize: json['orders_ring_size']?.toString() ?? '',
      ordersReadyDate:
          json['orders_ready_date'] != null && json['orders_ready_date'] != ''
              ? DateTime.tryParse(json['orders_ready_date'].toString())
              : null,
      ordersPickupDate:
          json['orders_pickup_date'] != null && json['orders_pickup_date'] != ''
              ? DateTime.tryParse(json['orders_pickup_date'].toString())
              : null,
      ordersGoldPricePerGram:
          json['orders_gold_price_per_gram'] != null
              ? double.tryParse(
                    json['orders_gold_price_per_gram'].toString(),
                  ) ??
                  0
              : 0,
      ordersFinalPrice:
          json['orders_final_price'] != null
              ? double.tryParse(json['orders_final_price'].toString()) ?? 0
              : 0,
      ordersDp:
          json['orders_dp'] != null
              ? double.tryParse(json['orders_dp'].toString()) ?? 0
              : 0,
      ordersSisaLunas:
          json['orders_sisa_lunas'] != null
              ? double.tryParse(json['orders_sisa_lunas'].toString()) ?? 0
              : 0,
      ordersNote: json['orders_note']?.toString() ?? '',
      ordersUpdatedAt:
          json['orders_updated_at'] != null && json['orders_updated_at'] != ''
              ? DateTime.tryParse(json['orders_updated_at'].toString())
              : null,
      ordersImagePaths: parseImagePaths(json['orders_imagePaths']),
      ordersWorkflowStatus: OrderWorkflowStatusX.fromString(
        json['orders_workflowStatus'],
      ),
      ordersDesignerWorkChecklist: parseChecklist(
        json['orders_designerWorkChecklist'],
      ),
      ordersCastingWorkChecklist: parseChecklist(
        json['orders_castingWorkChecklist'],
      ),
      ordersCarvingWorkChecklist: parseChecklist(
        json['orders_carvingWorkChecklist'],
      ),
      ordersDiamondSettingWorkChecklist: parseChecklist(
        json['orders_diamondSettingWorkChecklist'],
      ),
      ordersFinishingWorkChecklist: parseChecklist(
        json['orders_finishingWorkChecklist'],
      ),
      inventoryProductId: json['inventory_product_id']?.toString() ?? '',
      inventoryJewelryType: json['inventory_jewelry_type']?.toString() ?? '',
      inventoryGoldColor: json['inventory_gold_color']?.toString() ?? '',
      inventoryGoldType: json['inventory_gold_type']?.toString() ?? '',
      inventoryStoneUsed:
          json['inventory_stone_used'] != null
              ? List<Map<String, dynamic>>.from(
                json['inventory_stone_used'].map(
                  (e) => Map<String, dynamic>.from(e),
                ),
              )
              : null,
      inventoryImagePaths:
          json['inventory_imagePaths'] != null
              ? parseImagePaths(json['inventory_imagePaths'])
              : [],
      inventoryItemsPrice:
          json['inventory_items_price'] != null
              ? double.tryParse(json['inventory_items_price'].toString()) ?? 0
              : null,
      inventoryRingSize: json['inventory_ring_size']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders_id': ordersId,
      'orders_customer_name': ordersCustomerName,
      'orders_customer_contact': ordersCustomerContact,
      'orders_address': ordersAddress,
      'orders_jewelry_type': ordersJewelryType,
      'orders_created_at': ordersCreatedAt.toIso8601String(),
      'orders_gold_color': ordersGoldColor,
      'orders_gold_type': ordersGoldType,
      'orders_ring_size': ordersRingSize,
      'orders_ready_date': ordersReadyDate?.toIso8601String(),
      'orders_pickup_date': ordersPickupDate?.toIso8601String(),
      'orders_gold_price_per_gram': ordersGoldPricePerGram,
      'orders_final_price': ordersFinalPrice,
      'orders_dp': ordersDp,
      'orders_sisa_lunas': ordersSisaLunas,
      'orders_note': ordersNote,
      'orders_updated_at': ordersUpdatedAt?.toIso8601String(),
      'orders_imagePaths': ordersImagePaths,
      'orders_workflowStatus': ordersWorkflowStatus.name,
      'orders_designerWorkChecklist': ordersDesignerWorkChecklist,
      'orders_castingWorkChecklist': ordersCastingWorkChecklist,
      'orders_carvingWorkChecklist': ordersCarvingWorkChecklist,
      'orders_diamondSettingWorkChecklist': ordersDiamondSettingWorkChecklist,
      'orders_finishingWorkChecklist': ordersFinishingWorkChecklist,
      'inventory_product_id': inventoryProductId,
      'inventory_jewelry_type': inventoryJewelryType,
      'inventory_gold_color': inventoryGoldColor,
      'inventory_gold_type': inventoryGoldType,
      'inventory_stone_used': inventoryStoneUsed,
      'inventory_imagePaths': inventoryImagePaths,
      'inventory_items_price': inventoryItemsPrice,
      'inventory_ring_size': inventoryRingSize,
    };
  }
}
