import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/category.dart';
import '../models/combo_item.dart';
import '../models/product.dart';
import '../models/transaction.dart' as models;
import '../models/transaction_item.dart';
import '../models/user.dart';
import '../utils/uuid_generator.dart';

/// Local SQLite access: auth, settings, and dashboard aggregates.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  final AppDatabase _db = AppDatabase();

  Future<void> initialize() async {
    await _db.database;
  }

  Future<User?> authenticateUser(String username, String password) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      columns: ['username', 'display_name', 'role'],
      where: 'username = ? AND password = ?',
      whereArgs: [username.trim(), password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final roleName = row['role']! as String;
    return User(
      username: row['username']! as String,
      displayName: row['display_name']! as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == roleName,
        orElse: () => UserRole.cashier,
      ),
    );
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await _db.database;
    final rows = await db.query('app_settings');
    return {
      for (final r in rows) r['key']! as String: r['value']! as String,
    };
  }

  Future<String?> getSetting(String key) async {
    final db = await _db.database;
    final rows = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await _db.database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------------------------------------------------------------------
  // Dashboard metrics
  // ---------------------------------------------------------------------------

  Future<int> getTodayOrdersCount() async {
    final db = await _db.database;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end =
        DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM transactions WHERE created_at BETWEEN ? AND ? AND status = 'completed'",
      [start, end],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<double> getTodayRevenue() async {
    final db = await _db.database;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end =
        DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(total), 0) as revenue FROM transactions WHERE created_at BETWEEN ? AND ? AND status = 'completed'",
      [start, end],
    );
    return (result.first['revenue'] as num?)?.toDouble() ?? 0;
  }

  Future<int> getPendingSyncCount() async => 0;

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  Future<int> insertCategory(Category category) async {
    final db = await _db.database;
    return db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories({bool activeOnly = true}) async {
    final db = await _db.database;
    final maps = activeOnly
        ? await db.query(
            'categories',
            where: 'is_active = ?',
            whereArgs: [1],
            orderBy: 'name ASC',
          )
        : await db.query('categories', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    final db = await _db.database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deactivateCategory(String id) async {
    final db = await _db.database;
    final now = DateTime.now();
    return db.update(
      'categories',
      {
        'is_active': 0,
        'updated_at': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> reactivateCategory(String id) async {
    final db = await _db.database;
    final now = DateTime.now();
    return db.update(
      'categories',
      {
        'is_active': 1,
        'updated_at': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  Future<int> insertProduct(Product product) async {
    final db = await _db.database;
    return db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await _db.database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<List<Product>> getAllProducts({bool activeOnly = true}) async {
    final db = await _db.database;
    final maps = activeOnly
        ? await db.query(
            'products',
            where: 'is_active = ?',
            whereArgs: [1],
            orderBy: 'name ASC',
          )
        : await db.query('products', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await _db.database;
    final maps = await db.query(
      'products',
      where: 'category = ? AND is_active = ?',
      whereArgs: [category, 1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProductById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<int> deactivateProduct(String id) async {
    final db = await _db.database;
    final now = DateTime.now();
    return db.update(
      'products',
      {
        'is_active': 0,
        'updated_at': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> reactivateProduct(String id) async {
    final db = await _db.database;
    final now = DateTime.now();
    return db.update(
      'products',
      {
        'is_active': 1,
        'updated_at': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getProductCountForCategory(String categoryName) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE category = ? AND is_active = ?',
      [categoryName, 1],
    );
    if (result.isEmpty) return 0;
    return result.first['count'] as int? ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Combo Items
  // ---------------------------------------------------------------------------

  Future<void> insertComboWithItems(
      Product combo, List<ComboItem> items) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.insert('products', combo.toMap());
      for (final item in items) {
        await txn.insert('combo_items', item.toMap());
      }
    });
  }

  Future<void> updateComboWithItems(
      Product combo, List<ComboItem> items) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update('products', combo.toMap(),
          where: 'id = ?', whereArgs: [combo.id]);
      await txn.delete('combo_items',
          where: 'combo_product_id = ?', whereArgs: [combo.id]);
      for (final item in items) {
        await txn.insert('combo_items', item.toMap());
      }
    });
  }

  Future<List<ComboItem>> getComboItems(String comboProductId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT ci.*, p.name as component_product_name, p.price as component_product_price
      FROM combo_items ci
      LEFT JOIN products p ON ci.component_product_id = p.id
      WHERE ci.combo_product_id = ?
    ''', [comboProductId]);
    return List.generate(maps.length, (i) => ComboItem.fromMap(maps[i]));
  }

  Future<void> deleteComboItems(String comboProductId) async {
    final db = await _db.database;
    await db.delete('combo_items',
        where: 'combo_product_id = ?', whereArgs: [comboProductId]);
  }

  // ---------------------------------------------------------------------------
  // Transactions
  // ---------------------------------------------------------------------------

  Future<String> generateTransactionNumber() async {
    final db = await _db.database;
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final prefix = 'TXN-$dateStr-';

    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM transactions WHERE transaction_number LIKE ?",
      ['$prefix%'],
    );
    final count = ((result.first['count'] as int?) ?? 0) + 1;
    return '$prefix${count.toString().padLeft(3, '0')}';
  }

  Future<models.Transaction> insertTransaction({
    required String cashierUsername,
    required double subtotal,
    required double discountPercentage,
    required double discountAmount,
    required double total,
    required List<TransactionItem> items,
    String paymentMethod = 'cash',
  }) async {
    final db = await _db.database;
    final txnId = UUIDGenerator.generate();
    final txnNumber = await generateTransactionNumber();
    final now = DateTime.now();

    final transaction = models.Transaction(
      id: txnId,
      transactionNumber: txnNumber,
      cashierUsername: cashierUsername,
      subtotal: subtotal,
      discountPercentage: discountPercentage,
      discountAmount: discountAmount,
      total: total,
      paymentMethod: paymentMethod,
      createdAt: now,
    );

    await db.transaction((txn) async {
      await txn.insert('transactions', transaction.toMap());
      for (final item in items) {
        final mapped = item.copyWith(
          transactionId: txnId,
          createdAt: now,
        );
        await txn.insert('transaction_items', mapped.toMap());
      }
    });

    return transaction;
  }

  Future<List<models.Transaction>> getAllTransactions({
    String? cashierUsername,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) async {
    final db = await _db.database;
    final whereParts = <String>[];
    final whereArgs = <Object>[];

    if (cashierUsername != null) {
      whereParts.add('t.cashier_username = ?');
      whereArgs.add(cashierUsername);
    }
    if (startDate != null) {
      whereParts.add('t.created_at >= ?');
      whereArgs.add(DateTime(startDate.year, startDate.month, startDate.day)
          .toIso8601String());
    }
    if (endDate != null) {
      whereParts.add('t.created_at <= ?');
      whereArgs.add(
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59)
              .toIso8601String());
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereParts.add('t.transaction_number LIKE ?');
      whereArgs.add('%$searchQuery%');
    }

    final whereClause =
        whereParts.isEmpty ? '' : 'WHERE ${whereParts.join(' AND ')}';

    final maps = await db.rawQuery('''
      SELECT t.*, COUNT(ti.id) as item_count
      FROM transactions t
      LEFT JOIN transaction_items ti ON t.id = ti.transaction_id
      $whereClause
      GROUP BY t.id
      ORDER BY t.created_at DESC
    ''', whereArgs);

    return List.generate(
        maps.length, (i) => models.Transaction.fromMap(maps[i]));
  }

  Future<models.Transaction?> getTransactionById(String id) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT t.*, COUNT(ti.id) as item_count
      FROM transactions t
      LEFT JOIN transaction_items ti ON t.id = ti.transaction_id
      WHERE t.id = ?
      GROUP BY t.id
    ''', [id]);
    if (maps.isEmpty) return null;
    return models.Transaction.fromMap(maps.first);
  }

  Future<List<TransactionItem>> getTransactionItems(
      String transactionId) async {
    final db = await _db.database;
    final maps = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'product_name ASC',
    );
    return List.generate(maps.length, (i) => TransactionItem.fromMap(maps[i]));
  }

  // ---------------------------------------------------------------------------
  // Wipe
  // ---------------------------------------------------------------------------

  Future<void> wipeDatabase() async {
    await _db.wipeDatabase();
  }
}
