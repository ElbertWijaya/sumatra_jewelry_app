import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class InventoryService {
  // API: Get inventory list from remote server
  Future<List<Inventory>> getInventoryList() async {
    final response = await http.get(
      Uri.parse('http://192.168.110.147/sumatra_api/get_inventory_list.php'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Inventory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load inventory');
    }
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
}
