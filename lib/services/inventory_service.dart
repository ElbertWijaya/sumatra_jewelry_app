import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'auth_service.dart';

class InventoryService {
  // API: Get inventory list from remote server
  Future<List<Inventory>> getInventoryList() async {
    try {
      print('DEBUG: Calling get_inventory.php...');
      final response = await http.get(
        Uri.parse('http://192.168.110.147/sumatra_api/get_inventory.php'),
      );
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('DEBUG: Parsed ${data.length} inventory items');
        return data.map((e) => Inventory.fromJson(e)).toList();
      } else {
        throw Exception(
          'Failed to load inventory - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('DEBUG: Exception in getInventoryList: $e');
      rethrow;
    }
  }

  // API: Update inventory data
  Future<bool> updateInventoryAPI(Inventory inventory) async {
    // Dapatkan user ID untuk history tracking
    final authService = AuthService();
    final currentUserId = authService.currentUserId;

    final response = await http.post(
      Uri.parse(
        'http://192.168.110.147/sumatra_api/update_inventory_with_history.php',
      ),
      body: {
        'inventory_id': inventory.InventoryId,
        'inventory_product_id': inventory.InventoryProductId,
        'inventory_jewelry_type': inventory.InventoryJewelryType ?? '',
        'inventory_gold_type': inventory.InventoryGoldType ?? '',
        'inventory_gold_color': inventory.InventoryGoldColor ?? '',
        'inventory_ring_size': inventory.InventoryRingSize ?? '',
        'inventory_items_price': inventory.InventoryItemsPrice ?? '0',
        'inventory_imagePaths': jsonEncode(inventory.InventoryImagePaths),
        'inventory_stone_used': jsonEncode(inventory.InventoryStoneUsed),
        // Tambahkan user ID untuk history tracking
        'updated_by': currentUserId ?? '0',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['success'] == true;
    }
    return false;
  }

  // SQLite: Insert inventory
  Future<void> insertInventory(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'inventory',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // SQLite: Get all inventory
  Future<List<Map<String, dynamic>>> getAllInventory() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('inventory');
  }

  // SQLite: Get inventory by ID
  Future<Map<String, dynamic>?> getInventoryById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'inventory',
      where: 'inventory_product_id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // SQLite: Delete inventory
  Future<void> deleteInventory(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'inventory',
      where: 'inventory_product_id = ?',
      whereArgs: [id],
    );
  }

  // SQLite: Update inventory
  Future<void> updateInventory(String id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'inventory',
      data,
      where: 'inventory_product_id = ?',
      whereArgs: [id],
    );
  }

  // Inventory History methods
  Future<List<Map<String, dynamic>>> getInventoryHistory(
    String inventoryId,
  ) async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.110.147/sumatra_api/get_history.php?type=inventory&inventory_id=$inventoryId',
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }
    throw Exception('Gagal memuat history inventory: ${response.statusCode}');
  }

  Future<List<Map<String, dynamic>>> getInventoryTimeline(
    String inventoryId,
  ) async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.110.147/sumatra_api/get_history.php?type=inventory_timeline&inventory_id=$inventoryId',
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }
    throw Exception('Gagal memuat timeline inventory: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getInventorySnapshot(
    String inventoryId,
    DateTime? date,
  ) async {
    String url =
        'http://192.168.110.147/sumatra_api/get_history.php?type=inventory_snapshot&inventory_id=$inventoryId';
    if (date != null) {
      url += '&date=${date.toIso8601String()}';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data'];
      }
    }
    throw Exception('Gagal memuat snapshot inventory: ${response.statusCode}');
  }

  Future<bool> logInventoryHistory({
    required String inventoryId,
    required String action,
    required String description,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    final authService = AuthService();
    final currentUserId = authService.currentUserId;

    final Map<String, String> body = {
      'inventory_id': inventoryId,
      'action': action,
      'description': description,
      'changed_by': currentUserId ?? '0',
    };

    if (oldData != null) {
      body['old_data'] = jsonEncode(oldData);
    }
    if (newData != null) {
      body['new_data'] = jsonEncode(newData);
    }

    final response = await http.post(
      Uri.parse('http://192.168.110.147/sumatra_api/history_logger.php'),
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  }
}
