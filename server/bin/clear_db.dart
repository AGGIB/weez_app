import '../lib/config/env.dart';
import '../lib/db/database.dart';

void main() async {
  print(
    'WARNING: This will delete ALL users, stores, products, orders, and reviews.',
  );
  print('Starting cleanup...');

  final db = AppDatabase();

  try {
    // 1. Delete dependent transactional data first
    print('Deleting order items...');
    await db.execute('DELETE FROM order_items');

    print('Deleting orders...');
    await db.execute('DELETE FROM orders');

    print('Deleting reviews...');
    await db.execute('DELETE FROM reviews');

    // 2. Delete products (since they might link to stores)
    print('Deleting products...');
    await db.execute('DELETE FROM products');

    // 3. Delete stores (linked to users)
    print('Deleting stores...');
    await db.execute('DELETE FROM stores');

    // 4. Finally delete users
    print('Deleting users...');
    await db.execute('DELETE FROM users');

    print('Database cleared successfully!');
  } catch (e) {
    print('Error clearing database: $e');
  } finally {
    // Check if we need to dispose, but AppDatabase mostly keeps pool open.
    // In a script, we should exit.
    // The db class has a dispose method?
    await db.dispose();
  }
}
