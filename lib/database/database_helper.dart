import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/shopping_item.dart';
import '../data/initial_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shopping_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE products ADD COLUMN imageBase64 TEXT');
      await db.execute('ALTER TABLE cart ADD COLUMN imageBase64 TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        price $realType,
        description $textType,
        imageBase64 TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cart (
        id $idType,
        productId $integerType,
        name $textType,
        price $realType,
        quantity $integerType,
        imageBase64 TEXT
      )
    ''');

    // Populate initial data
    for (var product in initialProducts) {
      await db.insert('products', product.toMap());
    }
  }

  // --- Product Operations ---
  Future<List<ShoppingItem>> getProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => ShoppingItem.fromMap(json)).toList();
  }

  Future<void> insertProduct(ShoppingItem product) async {
    final db = await instance.database;
    await db.insert('products', product.toMap());
  }

  Future<void> updateProduct(ShoppingItem product) async {
    final db = await instance.database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await instance.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Also remove from cart
    await db.delete(
      'cart',
      where: 'productId = ?',
      whereArgs: [id],
    );
  }

  // --- Cart Operations ---
  Future<List<CartItem>> getCartItems() async {
    final db = await instance.database;
    final result = await db.query('cart');
    return result.map((json) => CartItem.fromMap(json)).toList();
  }

  Future<void> addToCart(ShoppingItem product) async {
    final db = await instance.database;
    
    // Check if item already exists in cart
    final existing = await db.query(
      'cart',
      where: 'productId = ?',
      whereArgs: [product.id],
    );

    if (existing.isNotEmpty) {
      // Increase quantity
      final cartItem = CartItem.fromMap(existing.first);
      cartItem.quantity += 1;
      await db.update(
        'cart',
        cartItem.toMap(),
        where: 'id = ?',
        whereArgs: [cartItem.id],
      );
    } else {
      // Add new item
      final cartItem = CartItem(
        productId: product.id!,
        name: product.name,
        price: product.price,
        quantity: 1,
        imageBase64: product.imageBase64,
      );
      await db.insert('cart', cartItem.toMap());
    }
  }

  Future<void> updateCartItemQuantity(int id, int quantity) async {
    final db = await instance.database;
    if (quantity <= 0) {
      await removeFromCart(id);
    } else {
      await db.update(
        'cart',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> removeFromCart(int id) async {
    final db = await instance.database;
    await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearCart() async {
    final db = await instance.database;
    await db.delete('cart');
  }
}
