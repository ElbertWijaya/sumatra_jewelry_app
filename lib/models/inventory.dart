import 'dart:convert';

class InventoryItem {
  final int? inventoryId; // <--- Tambahan
  final String id;
  final String jewelryType;
  final String goldColor;
  final String goldType;
  final String? ringSize;
  final double? itemsPrice;
  final List<String> imagePaths;
  final List<Map<String, dynamic>>? stoneUsed;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  InventoryItem({
    this.inventoryId, // <--- Tambahan
    required this.id,
    required this.jewelryType,
    required this.goldColor,
    required this.goldType,
    this.ringSize,
    this.itemsPrice,
    this.imagePaths = const [],
    this.stoneUsed,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    List<String> parseImagePaths(dynamic val) {
      if (val == null) return [];
      if (val is List) return List<String>.from(val.map((e) => e.toString()));
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) return List<String>.from(decoded.map((e) => e.toString()));
        } catch (_) {}
      }
      return [];
    }
    List<Map<String, dynamic>> parseStoneUsed(dynamic val) {
      if (val == null) return [];
      if (val is List) return List<Map<String, dynamic>>.from(val.map((e) => Map<String, dynamic>.from(e)));
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) return List<Map<String, dynamic>>.from(decoded.map((e) => Map<String, dynamic>.from(e)));
        } catch (_) {}
      }
      return [];
    }
    return InventoryItem(
      inventoryId: map['inventory_id'] != null ? int.tryParse(map['inventory_id'].toString()) : null, // <--- Tambahan
      id: map['inventory_product_id']?.toString() ?? '',
      jewelryType: map['inventory_jewelry_type']?.toString() ?? '',
      goldColor: map['inventory_gold_color']?.toString() ?? '',
      goldType: map['inventory_gold_type']?.toString() ?? '',
      ringSize: map['inventory_ring_size']?.toString(),
      itemsPrice: map['inventory_items_price'] != null ? double.tryParse(map['inventory_items_price'].toString()) : null,
      imagePaths: parseImagePaths(map['inventory_imagePaths']),
      stoneUsed: parseStoneUsed(map['inventory_stone_used']),
      notes: null,
      createdAt: map['inventory_created_at']?.toString(),
      updatedAt: map['inventory_updated_at']?.toString(),
    );
  }
}
