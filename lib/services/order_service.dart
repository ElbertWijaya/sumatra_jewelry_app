import 'package:sqflite/sqflite.dart';
import '../models/order.dart';
import 'database_helper.dart';

class OrderService {
  final dbHelper = DatabaseHelper();

  Future<List<Order>> getOrders() async {
    final db = await dbHelper.db;
    final maps = await db.query('orders', orderBy: 'created_at DESC');
    print ('Isi table order: $maps');
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  Future<void> addOrder(Order order) async {
    final db = await dbHelper.db;
    print('Mencoba insert order: ${order.toMap()}');
    try {
      await db.insert(
        'orders',
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Insert sukses');
    } catch (e, stack) {
      print('Insert GAGAL: $e');
      print(stack);
    }
  }

  Future<void> updateOrder(Order order) async {
    final db = await dbHelper.db;
    await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<void> deleteOrder(String id) async {
    final db = await dbHelper.db;
    await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Order?> getOrderById(String id) async {
    final db = await dbHelper.db;
    final maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Order.fromMap(maps.first);
    }
    return null;
  }
}