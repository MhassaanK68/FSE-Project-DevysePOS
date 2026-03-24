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

  static const List<String> allTables = [
    usersTable,
    appSettingsTable,
  ];

  static const String usersUsernameIndex = '''
    CREATE INDEX idx_users_username ON users(username)
  ''';

  static const List<String> allIndexes = [
    usersUsernameIndex,
  ];
}
