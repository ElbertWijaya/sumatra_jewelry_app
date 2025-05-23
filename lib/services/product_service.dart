import 'package:flutter/foundation.dart';

/// Simple Product model for demonstration.
/// Expand as needed or import from your models.
class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  Product copyWith({String? id, String? name, double? price}) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
}

/// Dummy ProductService for demonstration and future backend integration.
class ProductService {
  static final ProductService _instance = ProductService._internal();

  factory ProductService() => _instance;

  ProductService._internal();

  final List<Product> _dummyProducts = [
    Product(id: '1', name: 'Product A', price: 10000),
    Product(id: '2', name: 'Product B', price: 20000),
  ];

  /// Fetches a copy of all products.
  Future<List<Product>> getProducts() async {
    try {
      // TODO: Replace with real API request.
      await Future.delayed(const Duration(milliseconds: 500));
      return List<Product>.from(_dummyProducts);
    } catch (e, stack) {
      debugPrint('ProductService.getProducts error: $e\n$stack');
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Adds a new product.
  Future<void> addProduct(Product product) async {
    try {
      // TODO: Replace with real API request.
      await Future.delayed(const Duration(milliseconds: 500));
      _dummyProducts.add(product);
    } catch (e, stack) {
      debugPrint('ProductService.addProduct error: $e\n$stack');
      rethrow;
    }
  }

  /// Updates an existing product by ID.
  Future<void> updateProduct(Product product) async {
    try {
      // TODO: Replace with real API request.
      await Future.delayed(const Duration(milliseconds: 500));
      final idx = _dummyProducts.indexWhere((p) => p.id == product.id);
      if (idx != -1) {
        _dummyProducts[idx] = product;
      } else {
        throw Exception('Product not found');
      }
    } catch (e, stack) {
      debugPrint('ProductService.updateProduct error: $e\n$stack');
      rethrow;
    }
  }

  /// Removes a product by ID.
  Future<void> deleteProduct(String productId) async {
    try {
      // TODO: Replace with real API request.
      await Future.delayed(const Duration(milliseconds: 500));
      _dummyProducts.removeWhere((p) => p.id == productId);
    } catch (e, stack) {
      debugPrint('ProductService.deleteProduct error: $e\n$stack');
      rethrow;
    }
  }

  /// Fetches a single product by ID.
  Future<Product?> getProductById(String productId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _dummyProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );
    } catch (e, stack) {
      debugPrint('ProductService.getProductById error: $e\n$stack');
      return null;
    }
  }

  // For testing: reset all products
  void clearDummyProducts() {
    _dummyProducts.clear();
  }
}
