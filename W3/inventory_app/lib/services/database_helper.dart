//database_helper.dart
import 'package:sqflite/sqflite.dart';
//thu vien xu ly path
import 'package:path/path.dart' as p;
import '../models/product.dart';
import '../models/deal.dart';


//khoi tao vao quan ly sqlite
class DatabaseHelper {
  //chi duy nhat 1 doi tuong data tranh ket noi voi nhieu se ton tai nguyen
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  //getter de truy cap database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  //ham tao va mo database de luu toan bo du lieu
  Future<Database> _initDB(String filePath) async {
    //tao file neu chua co, neu co thi lay path cua file va mo
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);


    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  //ham tao 2 bang
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE products (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      quantity INTEGER NOT NULL
    )
    ''');//luu san pham

    await db.execute('''
    CREATE TABLE deals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id TEXT NOT NULL,
      type TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      timestamp TEXT NOT NULL
    )
    ''');//luu nhap/xuat
  }

  //nang cap database
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create the deals table if it doesn't exist
      await db.execute('''
      CREATE TABLE IF NOT EXISTS deals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
      ''');
    }
  }

  // Product methods
  //kiem tra san pham ton tai chua
  Future<bool> productExists(String id) async {
    final db = await instance.database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  //them moi san pham
  Future<int> createProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', product.toMap());
  }

  //truy van thong tin san pham
  Future<Product?> getProduct(String id) async {
    final db = await instance.database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  //truy van tat ca
  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  //cap nhat so luong san pham theo id
  Future<int> updateProductQuantity(String id, int newQuantity) async {
    final db = await instance.database;
    return await db.update(
      'products',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deal methods
  //them nhap/xuat
  Future<int> addDeal(Deal deal) async {
    final db = await instance.database;
    return await db.insert('deals', deal.toMap());
  }

  //xem lich su
  Future<List<Deal>> getProductDeals(String productId) async {
    final db = await instance.database;
    final result = await db.query(
      'deals',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'timestamp DESC',
    );

    return result.map((map) => Deal.fromMap(map)).toList();
  }

  //hien thi tat ca lich su
  Future<List<Deal>> getAllDeals() async {
    final db = await instance.database;
    final result = await db.query('deals', orderBy: 'timestamp DESC');

    return result.map((map) => Deal.fromMap(map)).toList();
  }

  //xoa du lieu
  Future<int> delete(
    String table,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  //For debugging - check if a table exists
  Future<bool> tableExists(String tableName) async {
    final db = await instance.database;
    var tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return tables.isNotEmpty;
  }
}
