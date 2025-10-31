//database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

//tao csdl, ket noi va tuong tac csdl voi sqlite

//tao co so du lieu
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  //dam bao tra ve _instance
  factory DatabaseHelper() => _instance;
  //truy xuat du lieu
  static Database? _database; //ket noi

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  //khoi tao csdl
  Future<Database> _initDatabase() async {
    //path la noi luu tru cua thu muc du lieu
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'products.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  //tao bang trong csdl va them du lieu mau vao csdl
  //tao bang ten products
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        qr_code TEXT PRIMARY KEY,
        product_name TEXT,
        product_type TEXT,
        weight REAL,
        farm_name TEXT,
        farm_address TEXT,
        certification TEXT,
        planting_date TEXT,
        harvest_date TEXT,
        farming_method TEXT
      )
    ''');

    // Thêm dữ liệu mẫu vao csdl
    await _addSampleProducts(db);
  }


  Future<void> _addSampleProducts(Database db) async {
    await db.insert('products', {
      'qr_code': 'XOAI_CAT_001',
      'product_name': 'Xoài cát Hòa Lộc',
      'product_type': 'Xoài cát',
      'weight': 1.0,
      'farm_name': 'Nông trại An Lạc',
      'farm_address': 'Ấp 3, xã Hòa Lộc, huyện Cái Bè, tỉnh Tiền Giang',
      'certification': 'VietGAP',
      'planting_date': '2022-03-15',
      'harvest_date': '2023-06-20',
      'farming_method': 'Hữu cơ'
    });

    await db.insert('products', {
      'qr_code': 'CAM_SANH_002',
      'product_name': 'Cam sành',
      'product_type': 'Cam',
      'weight': 0.8,
      'farm_name': 'Vườn cam Vĩnh Long',
      'farm_address': 'Vĩnh Long',
      'certification': 'GlobalGAP',
      'planting_date': '2022-11-10',
      'harvest_date': '2023-05-15',
      'farming_method': 'An toàn'
    });
  }

  //truy van theo qr code
  //tim product co qrcode
  Future<Map<String, dynamic>?> getProductByQrCode(String qrCode) async {
    final db = await database;
    final result = await db.query(
      'products',
      //cach truy van sql: loc
      where: 'qr_code = ?',
      whereArgs: [qrCode],
    );
    return result.isNotEmpty ? result.first : null;
  }
}