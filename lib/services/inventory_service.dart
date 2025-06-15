import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class InventoryService {
  Future<void> insertInventory(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'inventory',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllInventory() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('inventory');
  }

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

  Future<void> deleteInventory(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'inventory',
      where: 'inventory_product_id = ?',
      whereArgs: [id],
    );
  }

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