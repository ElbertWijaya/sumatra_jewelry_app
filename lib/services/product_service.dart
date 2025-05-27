import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

/// ProductService with real API integration.
/// Update the baseUrl to your backend endpoint.
class ProductService {
  static final ProductService _instance = ProductService._internal();

  factory ProductService() => _instance;

  ProductService._internal();

  // Ganti dengan endpoint backend Anda
  static const String baseUrl = 'https://your-api-url.com/api/products';

  /// Fetches all products from API.
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('ProductService.getProducts error: $e\n$stack');
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Adds a new product via API.
  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('ProductService.addProduct error: $e\n$stack');
      rethrow;
    }
  }

  /// Updates an existing product by ID via API.
  Future<void> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('ProductService.updateProduct error: $e\n$stack');
      rethrow;
    }
  }

  /// Removes a product by ID via API.
  Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$productId'));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('ProductService.deleteProduct error: $e\n$stack');
      rethrow;
    }
  }

  /// Fetches a single product by ID via API.
  Future<Product?> getProductById(String productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$productId'));
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch product: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('ProductService.getProductById error: $e\n$stack');
      return null;
    }
  }
}
