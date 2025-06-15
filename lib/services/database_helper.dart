import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sumatra_jewelry.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE inventory (
        inventory_product_id TEXT PRIMARY KEY,
        inventory_jewelry_type TEXT,
        inventory_gold_type TEXT,
        inventory_gold_color TEXT,
        inventory_ring_size TEXT,
        inventory_items_price REAL,
        inventory_created_at TEXT,
        inventory_imagePaths TEXT,
        inventory_stone_used TEXT
      )
    ''');
    // Tambahkan table lain jika diperlukan
  }
}