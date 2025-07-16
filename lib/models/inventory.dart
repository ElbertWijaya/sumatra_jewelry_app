import 'dart:convert';

class Inventory {
  final String InventoryId;
  final String InventoryProductId;
  final String? InventoryJewelryType;
  final String? InventoryGoldType;
  final String? InventoryGoldColor;
  final String? InventoryRingSize;
  final String? InventoryItemsPrice;
  final DateTime? InventoryCreatedAt;
  final DateTime? InventoryUpdatedAt;
  final List<String> InventoryImagePaths;
  final List<Map<String, dynamic>> InventoryStoneUsed;

  Inventory({
    required this.InventoryId,
    required this.InventoryProductId,
    this.InventoryJewelryType,
    this.InventoryGoldType,
    this.InventoryGoldColor,
    this.InventoryRingSize,
    this.InventoryItemsPrice,
    this.InventoryCreatedAt,
    this.InventoryUpdatedAt,
    required this.InventoryImagePaths,
    required this.InventoryStoneUsed,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      InventoryId: json['inventory_id'] ?? '',
      InventoryProductId: json['inventory_product_id'] ?? '',
      InventoryJewelryType: json['inventory_jewelry_type'],
      InventoryGoldType: json['inventory_gold_type'],
      InventoryGoldColor: json['inventory_gold_color'],
      InventoryRingSize: json['inventory_ring_size'],
      InventoryItemsPrice: json['inventory_items_price']?.toString(),
      InventoryCreatedAt:
          json['inventory_created_at'] != null
              ? DateTime.tryParse(json['inventory_created_at'])
              : null,
      InventoryUpdatedAt:
          json['inventory_updated_at'] != null
              ? DateTime.tryParse(json['inventory_updated_at'])
              : null,
      InventoryImagePaths:
          (json['inventory_imagePaths'] is List)
              ? List<String>.from(json['inventory_imagePaths'])
              : (json['inventory_imagePaths'] is String &&
                  json['inventory_imagePaths'].isNotEmpty)
              ? List<String>.from(jsonDecode(json['inventory_imagePaths']))
              : [],
      InventoryStoneUsed:
          (json['inventory_stone_used'] is List)
              ? List<Map<String, dynamic>>.from(json['inventory_stone_used'])
              : (json['inventory_stone_used'] is String &&
                  json['inventory_stone_used'].isNotEmpty)
              ? List<Map<String, dynamic>>.from(
                jsonDecode(json['inventory_stone_used']),
              )
              : [],
    );
  }
}

// InventoryItem class dihapus. Gunakan satu model Inventory saja dengan penamaan konsisten PascalCase.
