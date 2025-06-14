import 'dart:convert';

class Inventory {
  final String id;
  final String orderId;
  final String productId;
  final String jewelryType;
  final String goldType;
  final String goldColor;
  final String ringSize;
  final double itemsPrice;
  final List<String> imagePaths;
  final List<Map<String, String>> stoneUsed;
  final String createdAt;
  final String updatedAt;

  Inventory({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.jewelryType,
    required this.goldType,
    required this.goldColor,
    required this.ringSize,
    required this.itemsPrice,
    required this.imagePaths,
    required this.stoneUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'order_id': orderId,
    'product_id': productId,
    'jewelry_type': jewelryType,
    'gold_type': goldType,
    'gold_color': goldColor,
    'ring_size': ringSize,
    'items_price': itemsPrice,
    'image_paths': jsonEncode(imagePaths),
    'stone_used': jsonEncode(stoneUsed),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory Inventory.fromMap(Map<String, dynamic> map) => Inventory(
    id: map['id'],
    orderId: map['order_id'],
    productId: map['product_id'],
    jewelryType: map['jewelry_type'],
    goldType: map['gold_type'],
    goldColor: map['gold_color'],
    ringSize: map['ring_size'],
    itemsPrice: map['items_price'] is double ? map['items_price'] : double.tryParse(map['items_price'].toString()) ?? 0,
    imagePaths: List<String>.from(jsonDecode(map['image_paths'] ?? '[]')),
    stoneUsed: List<Map<String, String>>.from(jsonDecode(map['stone_used'] ?? '[]')),
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
  );
}