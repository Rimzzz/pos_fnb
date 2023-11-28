import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:pos_amazink/models/category.dart';
import 'package:pos_amazink/models/order_item.dart';
import 'package:pos_amazink/models/product.dart';

// import '../models/note.dart';

class AmazinkDatabase {
  AmazinkDatabase._init();

  static final AmazinkDatabase instance = AmazinkDatabase._init();

  final String tableCategory = 'category';
  final String tableProduct = 'product';
  final String tableOrder = 'order_table';
  final String tableOrderDetail = 'order_detail';
  final String tableCashout = 'cashout';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb('amazinktest11.db');
    return _database!;
  }

  Future _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCategory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_category TEXT NOT NULL,
        category_name TEXT NOT NULL,
        picture TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableProduct (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        price TEXT NOT NULL,
        picture TEXT NOT NULL,
        sku TEXT NOT NULL,
        category_id TEXT NOT NULL,
        category_name TEXT NOT NULL,
        is_active TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrder(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pay TEXT NOT NULL,
        total TEXT NOT NULL,
        transaction_date TEXT,
        transaction_time TEXT,
        is_updated TEXT NOT NULL,
        updated_time TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrderDetail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        category_name TEXT NOT NULL,
        qty TEXT NOT NULL,
        price TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCashout (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rekening TEXT NOT NULL,
        rekening_name TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        keperluan TEXT NOT NULL,
        nominal TEXT NOT NULL
      )
    ''');
  }

  Future<Database> _initDb(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<Category> createCategory(Category obj) async {
    final db = await instance.database;
    int id = await db.insert(tableCategory, obj.toMapLocalDb());

    return obj;
  }

  Future<int> createOrder({
    required String pay,
    required String total,
  }) async {
    final String tglNow = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String timeNow =
        DateFormat('yyyy-MM-dd HH.mm.ss').format(DateTime.now());
    final db = await instance.database;
    int id = await db.insert(
      tableOrder,
      {
        'pay': pay,
        'total': total,
        'transaction_time': timeNow,
        'transaction_date': tglNow,
        'is_updated': 0,
      },
    );

    return id;
  }

  Future<int> createCashout({
    required String rekening,
    required String rekening_name,
    required String tanggal,
    required String keperluan,
    required String nominal,
  }) async {
    final db = await instance.database;
    int id = await db.insert(
      tableCashout,
      {
        'rekening': rekening,
        'rekening_name': rekening_name,
        'tanggal': tanggal,
        'keperluan': keperluan,
        'nominal': nominal,
      },
    );

    return id;
  }

  Future<List<Cashout>> getCashoutByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      tableCashout,
      where: 'tanggal = ?',
      whereArgs: [date],
      orderBy: 'id desc',
    );

    return result.map((e) => Cashout.fromMap(e)).toList();
  }

  Future<int> createOrderDetail({
    required int orderId,
    required OrderItem item,
  }) async {
    final db = await instance.database;
    int id = await db.insert(
      tableOrderDetail,
      {
        'order_id': orderId,
        'product_id': item.product.productId,
        'product_name': item.product.productName,
        'category_name': item.product.categoryName,
        'qty': item.quantity,
        'price': item.product.price,
      },
    );

    return id;
  }

  Future<Product> createProduct(Product obj) async {
    final db = await instance.database;
    int id = await db.insert(tableProduct, obj.toMapLocalDb());

    return obj; //.copyWith(id: id);
  }

  Future<Category> readCategory(String id) async {
    final db = await instance.database;
    final maps = await db.query(tableCategory,
        columns: ['id', 'id_category', 'category_name', 'picture'],
        where: 'id_category = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Category.fromMapLocalDb(maps.first);
    } else {
      throw Exception('id $id not found');
    }
  }

  Future<List<Category>> readAllCategory() async {
    final db = await instance.database;
    final result = await db.query(tableCategory);

    return result.map((e) => Category.fromMapLocalDb(e)).toList();
  }

  Future<List<Product>> readAllProduct() async {
    final db = await instance.database;
    final result = await db.query(tableProduct);

    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Order>> readAllOrder() async {
    final db = await instance.database;
    final result = await db.query(
      tableOrder,
      where: 'is_updated = ?',
      whereArgs: [0],
      orderBy: 'id desc',
    );

    return result.map((e) => Order.fromMap(e)).toList();
  }

  Future<List<Order>> getOrdersByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      tableOrder,
      where: 'transaction_date = ?',
      whereArgs: [date],
      orderBy: 'id desc',
    );

    return result.map((e) => Order.fromMap(e)).toList();
  }

  Future<int> updateOrder(int id) async {
    final db = await instance.database;

    return db.update(
      tableOrder,
      {
        'is_updated': 1,
        'updated_time':
            DateFormat('yyyy-MM-dd HH.mm.ss').format(DateTime.now()),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<OrderDetail>> readAllOrderDetail(int id) async {
    final db = await instance.database;
    final result = await db.query(
      tableOrderDetail,
      where: 'order_id = ?',
      whereArgs: [id],
    );

    return result.map((e) => OrderDetail.fromMap(e)).toList();
  }

  // Future<int> update(Category note) async {
  //   final db = await instance.database;

  //   return db.update(
  //     tableCategory,
  //     note.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [note.id],
  //   );
  // }

  Future<int> deleteAllCategory() async {
    final db = await instance.database;

    return await db.delete(
      tableCategory,
    );
  }

  Future<int> deleteAllProduct() async {
    final db = await instance.database;

    return await db.delete(
      tableProduct,
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}

class Cashout {
  int id;
  String rekening;
  String rekening_name;
  String tanggal;
  String keperluan;
  String nominal;
  Cashout({
    required this.id,
    required this.rekening,
    required this.rekening_name,
    required this.tanggal,
    required this.keperluan,
    required this.nominal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rekening': rekening,
      'rekening_name': rekening_name,
      'tanggal': tanggal,
      'keperluan': keperluan,
      'nominal': nominal,
    };
  }

  factory Cashout.fromMap(Map<String, dynamic> map) {
    return Cashout(
      id: map['id']?.toInt() ?? 0,
      rekening: map['rekening'] ?? '',
      rekening_name: map['rekening_name'] ?? '',
      tanggal: map['tanggal'] ?? '',
      keperluan: map['keperluan'] ?? '',
      nominal: map['nominal'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Cashout.fromJson(String source) =>
      Cashout.fromMap(json.decode(source));
}

class OrderDetail {
  int id;
  String product_id;
  String product_name;
  String category_name;
  String qty;
  String price;
  OrderDetail({
    required this.id,
    required this.product_id,
    required this.product_name,
    required this.category_name,
    required this.qty,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': product_id,
      'product_name': product_name,
      'category_name': category_name,
      'qty': qty,
      'price': price,
    };
  }

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      id: map['id']?.toInt() ?? 0,
      product_id: map['product_id'] ?? '',
      product_name: map['product_name'] ?? '',
      category_name: map['category_name'] ?? '',
      qty: map['qty'] ?? '',
      price: map['price'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderDetail.fromJson(String source) =>
      OrderDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderDetail(id: $id, product_id: $product_id, product_name: $product_name, category_name: $category_name, qty: $qty, price: $price)';
  }
}

class Order {
  int id;
  String pay;
  String total;
  String transactionTime;
  String transactionDate;
  Order({
    required this.id,
    required this.pay,
    required this.total,
    required this.transactionTime,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pay': pay,
      'total': total,
      'transactionTime': transactionTime,
      'transactionDate': transactionDate,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id']?.toInt() ?? 0,
      pay: map['pay'] ?? '',
      total: map['total'] ?? '',
      transactionTime: map['transaction_time'] ?? '',
      transactionDate: map['transaction_date'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Order(id: $id, pay: $pay, total: $total, transactionTime: $transactionTime, transactionDate: $transactionDate)';
  }
}
