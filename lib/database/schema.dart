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

  static const String productsTable = '''
    CREATE TABLE products (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      price REAL NOT NULL,
      category TEXT NOT NULL,
      image_url TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      product_type TEXT NOT NULL DEFAULT 'regular',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT
    )
  ''';

  static const String transactionsTable = '''
    CREATE TABLE transactions (
      id TEXT PRIMARY KEY,
      transaction_number TEXT NOT NULL UNIQUE,
      cashier_username TEXT NOT NULL,
      subtotal REAL NOT NULL,
      discount_percentage REAL NOT NULL DEFAULT 0,
      discount_amount REAL NOT NULL DEFAULT 0,
      total REAL NOT NULL,
      payment_method TEXT NOT NULL DEFAULT 'cash',
      status TEXT NOT NULL DEFAULT 'completed',
      created_at TEXT NOT NULL
    )
  ''';

  static const String transactionItemsTable = '''
    CREATE TABLE transaction_items (
      id TEXT PRIMARY KEY,
      transaction_id TEXT NOT NULL,
      product_id TEXT NOT NULL,
      product_name TEXT NOT NULL,
      product_price REAL NOT NULL,
      quantity INTEGER NOT NULL,
      subtotal REAL NOT NULL,
      created_at TEXT NOT NULL
    )
  ''';

  static const String comboItemsTable = '''
    CREATE TABLE combo_items (
      id TEXT PRIMARY KEY,
      combo_product_id TEXT NOT NULL,
      component_product_id TEXT NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL
    )
  ''';

  static const List<String> allTables = [
    usersTable,
    appSettingsTable,
    categoriesTable,
    productsTable,
    transactionsTable,
    transactionItemsTable,
    comboItemsTable,
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

  static const String productsCategoryIndex = '''
    CREATE INDEX idx_products_category ON products(category)
  ''';

  static const String productsActiveIndex = '''
    CREATE INDEX idx_products_active ON products(is_active)
  ''';

  static const String transactionsNumberIndex = '''
    CREATE INDEX idx_transactions_number ON transactions(transaction_number)
  ''';

  static const String transactionsCreatedAtIndex = '''
    CREATE INDEX idx_transactions_created_at ON transactions(created_at)
  ''';

  static const String transactionsCashierIndex = '''
    CREATE INDEX idx_transactions_cashier ON transactions(cashier_username)
  ''';

  static const String transactionItemsTxnIndex = '''
    CREATE INDEX idx_transaction_items_txn ON transaction_items(transaction_id)
  ''';

  static const String comboItemsComboIndex = '''
    CREATE INDEX idx_combo_items_combo ON combo_items(combo_product_id)
  ''';

  static const List<String> allIndexes = [
    usersUsernameIndex,
    categoriesNameIndex,
    categoriesActiveIndex,
    productsCategoryIndex,
    productsActiveIndex,
    transactionsNumberIndex,
    transactionsCreatedAtIndex,
    transactionsCashierIndex,
    transactionItemsTxnIndex,
    comboItemsComboIndex,
  ];

  static const List<String> v4Tables = [
    transactionsTable,
    transactionItemsTable,
    comboItemsTable,
  ];

  static const List<String> v4Indexes = [
    transactionsNumberIndex,
    transactionsCreatedAtIndex,
    transactionsCashierIndex,
    transactionItemsTxnIndex,
    comboItemsComboIndex,
  ];
}
