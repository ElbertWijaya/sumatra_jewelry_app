import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "sumatra_jewelry.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        customer_name TEXT NOT NULL,
        customer_contact TEXT NOT NULL,
        address TEXT NOT NULL,
        jewelry_type TEXT NOT NULL,
        gold_color TEXT,
        gold_type TEXT,
        stone_type TEXT,
        stone_size TEXT,
        ring_size TEXT,
        ready_date TEXT,
        pickup_date TEXT,
        gold_price_per_gram REAL,
        final_price REAL,
        dp REAL,
        sisa_lunas REAL,
        notes TEXT,
        workflow_status TEXT NOT NULL,
        image_paths TEXT,
        designer_work_checklist TEXT,
        casting_work_checklist TEXT,
        carving_work_checklist TEXT,
        stone_setting_work_checklist TEXT,
        finishing_work_checklist TEXT,
        inventory_work_checklist TEXT,
        inventory_product_name TEXT,
        inventory_product_code TEXT,
        inventory_location TEXT,
        inventory_notes TEXT,
        inventory_shelf_location TEXT,
        assigned_designer TEXT,
        assigned_caster TEXT,
        assigned_carver TEXT,
        assigned_diamond_setter TEXT,
        assigned_finisher TEXT,
        assigned_inventory TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');
    // Tambahkan table lain (order_archive, inventory) jika perlu
  }
}