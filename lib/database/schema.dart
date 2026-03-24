class DatabaseSchema {
  static const String usersTable = '''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      username TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      display_name TEXT NOT NULL,
      role TEXT NOT NULL CHECK(role IN ('admin', 'cashier')),
      created_at TEXT NOT NULL
    )
  ''';

  static const String appSettingsTable = '''
    CREATE TABLE app_settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';

  static const String categoriesTable = '''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT
    )
  ''';

  static const List<String> allTables = [
    usersTable,
    appSettingsTable,
    categoriesTable,
  ];

  static const String usersUsernameIndex = '''
    CREATE INDEX idx_users_username ON users(username)
  ''';

  static const String categoriesNameIndex = '''
    CREATE INDEX idx_categories_name ON categories(name)
  ''';

  static const String categoriesActiveIndex = '''
    CREATE INDEX idx_categories_active ON categories(is_active)
  ''';

  static const List<String> allIndexes = [
    usersUsernameIndex,
    categoriesNameIndex,
    categoriesActiveIndex,
  ];
}
