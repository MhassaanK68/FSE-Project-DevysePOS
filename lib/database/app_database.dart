import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'schema.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  factory AppDatabase() => _instance;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'devyse_pos.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    for (final table in DatabaseSchema.allTables) {
      await db.execute(table);
    }
    for (final index in DatabaseSchema.allIndexes) {
      await db.execute(index);
    }
    await _seedUsers(db);
    await _seedDefaultSettings(db);
  }

  Future<void> _seedUsers(Database db) async {
    final now = DateTime.now().toIso8601String();
    final users = <Map<String, Object?>>[
      {
        'id': 'u_admin',
        'username': 'Rahman',
        'password': 'OmertaCafe@123',
        'display_name': 'Rahman',
        'role': 'admin',
        'created_at': now,
      },
      {
        'id': 'u_cashier',
        'username': 'Cashier',
        'password': 'CafeCsh@786',
        'display_name': 'Cashier',
        'role': 'cashier',
        'created_at': now,
      },
    ];
    for (final u in users) {
      await db.insert('users', u);
    }
  }

  Future<void> _seedDefaultSettings(Database db) async {
    final defaults = <String, String>{
      'store_name': 'Devyse Store',
      'receipt_footer': 'Thank you for your visit.',
    };
    for (final e in defaults.entries) {
      await db.insert('app_settings', {'key': e.key, 'value': e.value});
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> wipeDatabase() async {
    await close();
    final path = join(await getDatabasesPath(), 'devyse_pos.db');
    await sqflite.deleteDatabase(path);
    _database = await _initDatabase();
  }
}
