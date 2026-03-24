import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/category.dart';
import '../models/user.dart';

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

  /// Placeholder metrics until sales modules exist.
  Future<int> getTodayOrdersCount() async => 0;

  Future<double> getTodayRevenue() async => 0;

  Future<int> getPendingSyncCount() async => 0;

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

  /// No local products table yet; returns 0.
  Future<int> getProductCountForCategory(String categoryName) async => 0;

  Future<void> wipeDatabase() async {
    await _db.wipeDatabase();
  }
}
