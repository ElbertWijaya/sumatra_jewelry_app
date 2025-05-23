import 'package:flutter/foundation.dart';

/// Enum representing the possible statuses of an order.
enum OrderStatus { pending, processing, delivered, cancelled, unknown }

/// Extension for parsing OrderStatus from string.
extension OrderStatusX on OrderStatus {
  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        // Log unknown status for maintainability
        debugPrint('Unknown order status encountered: $status');
        return OrderStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.unknown:
      default:
        return 'Unknown';
    }
  }
}

/// Order item model representing a product in the order.
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  }) : assert(productId.isNotEmpty, 'Product ID cannot be empty.'),
       assert(productName.isNotEmpty, 'Product name cannot be empty.'),
       assert(quantity > 0, 'Quantity must be greater than 0.'),
       assert(price >= 0, 'Price cannot be negative.');

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? price,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'price': price,
  };
}

/// Order model representing an individual order.
class Order {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.notes,
  }) : assert(id.isNotEmpty, 'Order id cannot be empty.'),
       assert(customerName.isNotEmpty, 'Customer name cannot be empty.'),
       assert(items.isNotEmpty, 'Order must contain at least one item.');

  Order copyWith({
    String? id,
    String? customerName,
    List<OrderItem>? items,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      items: items ?? List<OrderItem>.from(this.items),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      items:
          (json['items'] as List<dynamic>)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList(),
      status: OrderStatusX.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'items': items.map((item) => item.toJson()).toList(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'notes': notes,
  };
}
