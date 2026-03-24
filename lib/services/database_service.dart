import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
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

  Future<void> wipeDatabase() async {
    await _db.wipeDatabase();
  }
}
