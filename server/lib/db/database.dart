import 'package:postgres/postgres.dart';
import '../config/env.dart';

class AppDatabase {
  late final Pool _pool;

  AppDatabase() {
    _init();
  }

  void _init() {
    final env = EnvConfig();
    _pool = Pool.withEndpoints([
      Endpoint(
        host: env.dbHost,
        port: env.dbPort,
        database: env.dbName,
        username: env.dbUser,
        password: env.dbPassword,
      ),
    ], settings: PoolSettings(sslMode: SslMode.disable));
    // Note: Tables creation should ideally be done via migration scripts or checks.
    // For this MVP, we will try to create them on start if not exist.
    // However, `_init` is synchronous in constructor, but DB ops are async.
    // We should move `createTables` to a separate async init method called from main.
  }

  Future<void> ensureInitialized() async {
    await _createTables();
  }

  Future<void> _createTables() async {
    // Users Table
    await execute('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        name TEXT,
        role TEXT DEFAULT 'buyer',
        store_name TEXT,
        bin TEXT,
        address TEXT,
        address TEXT,
        phone TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Attempt migrations for existing DB
    try {
      await execute(
        'ALTER TABLE users ADD COLUMN IF NOT EXISTS store_name TEXT;',
      );
    } catch (e) {
      print('Migration error (created_at): $e');
    }
    try {
      await execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS bin TEXT;');
    } catch (e) {
      print('Migration error (created_at): $e');
    }
    try {
      await execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS address TEXT;');
    } catch (e) {
      print('Migration error (created_at): $e');
    }
    try {
      await execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS phone TEXT;');
    } catch (e) {
      print('Migration error: $e');
    }

    try {
      await execute(
        'ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;',
      );
    } catch (e) {
      print('Migration error (created_at): $e');
    }

    // Stores Table
    await execute('''
      CREATE TABLE IF NOT EXISTS stores (
        id SERIAL PRIMARY KEY,
        seller_id INTEGER NOT NULL UNIQUE REFERENCES users(id),
        name TEXT NOT NULL,
        description TEXT,
        legal_info TEXT,
        logo_url TEXT,
        rating DOUBLE PRECISION DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Migrations for stores
    try {
      await execute(
        'ALTER TABLE stores ADD COLUMN IF NOT EXISTS logo_url TEXT;',
      );
    } catch (e) {
      print('Migration error (created_at): $e');
    }
    try {
      await execute(
        'ALTER TABLE stores ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;',
      );
    } catch (e) {
      print('Migration error (created_at): $e');
    }

    // Products Table
    await execute('''
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        store_id INTEGER REFERENCES stores(id),
        name TEXT NOT NULL,
        description TEXT,
        price DOUBLE PRECISION NOT NULL,
        category TEXT,
        image_url TEXT,
        image_urls TEXT,
        discount_price DOUBLE PRECISION DEFAULT 0,
        delivery_info TEXT,
        is_favorite BOOLEAN DEFAULT FALSE,
        rating DOUBLE PRECISION DEFAULT 0,
        reviews_count INTEGER DEFAULT 0
      );
    ''');

    // Migrations for products
    try {
      await execute(
        'ALTER TABLE products ADD COLUMN IF NOT EXISTS image_urls TEXT;',
      );
    } catch (e) {
      print('Migration error (created_at): $e');
    }
    try {
      await execute(
        'ALTER TABLE products ADD COLUMN IF NOT EXISTS discount_price DOUBLE PRECISION DEFAULT 0;',
      );
    } catch (e) {
      print('Migration error (created_at): $e');
    }
    try {
      await execute(
        'ALTER TABLE products ADD COLUMN IF NOT EXISTS delivery_info TEXT;',
      );
    } catch (e) {
      print('Migration error (created_at): $e');
    }

    // Reviews Table
    await execute('''
      CREATE TABLE IF NOT EXISTS reviews (
        id SERIAL PRIMARY KEY,
        product_id INTEGER NOT NULL REFERENCES products(id),
        user_id INTEGER NOT NULL REFERENCES users(id),
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Orders Table
    await execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        store_id INTEGER REFERENCES stores(id),
        total_amount DOUBLE PRECISION NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Order Items Table
    await execute('''
      CREATE TABLE IF NOT EXISTS order_items (
        id SERIAL PRIMARY KEY,
        order_id INTEGER NOT NULL REFERENCES orders(id),
        product_id INTEGER NOT NULL REFERENCES products(id),
        quantity INTEGER NOT NULL,
        price DOUBLE PRECISION NOT NULL
      );
    ''');

    // Seed if empty
    final result = await query('SELECT count(*) as "c" FROM products');
    if (result.isNotEmpty && result[0][0] == 0) {
      await _seedProducts();
    }
  }

  Future<void> _seedProducts() async {
    print('Seeding database with products...');
    final products = [
      [
        'iPhone 14 Pro',
        'Flagship smartphone',
        999.0,
        'Electronics',
        'https://via.placeholder.com/150',
      ],
      [
        'MacBook Air M2',
        'Laptop for everyone',
        1199.0,
        'Computers',
        'https://via.placeholder.com/150',
      ],
      [
        'AirPods Pro',
        'Active noise cancelling',
        249.0,
        'Audio',
        'https://via.placeholder.com/150',
      ],
      [
        'iPad Air',
        'Versatile tablet',
        599.0,
        'Tablets',
        'https://via.placeholder.com/150',
      ],
      [
        'Men T-Shirt',
        'Cotton basic',
        29.0,
        'Clothing',
        'https://via.placeholder.com/150',
      ],
    ];

    for (var p in products) {
      await execute(
        'INSERT INTO products (name, description, price, category, image_url) VALUES (@name, @description, @price, @category, @imageUrl)',
        substitutionValues: {
          'name': p[0],
          'description': p[1],
          'price': p[2],
          'category': p[3],
          'imageUrl': p[4],
        },
      );
    }
  }

  Future<List<List<dynamic>>> query(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    final result = await _pool.execute(
      Sql.named(sql),
      parameters: substitutionValues,
    );
    return result.toList();
  }

  // Helper to get Map<String, dynamic> from rows
  Future<List<Map<String, dynamic>>> queryMapped(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    final result = await _pool.execute(
      Sql.named(sql),
      parameters: substitutionValues,
    );

    // Result object has column info
    final columnNames = result.schema.columns.map((c) => c.columnName).toList();

    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < columnNames.length; i++) {
        final name = columnNames[i] ?? 'col_$i'; // Handle nullable column name
        map[name] = row[i];
      }
      return map;
    }).toList();
  }

  Future<void> execute(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    await _pool.execute(Sql.named(sql), parameters: substitutionValues);
  }

  Future<void> dispose() async {
    await _pool.close();
  }
}

// Global instance
final db = AppDatabase();
