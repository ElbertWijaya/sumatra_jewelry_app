import 'package:sqflite/sqflite.dart';
import '../models/inventory.dart';
import 'database_helper.dart';

class InventoryService {
  Future<void> insertInventory(Inventory inventory) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'inventory',
      inventory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Inventory>> getInventories() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('inventory');
    return maps.map((map) => Inventory.fromMap(map)).toList();
  }
}