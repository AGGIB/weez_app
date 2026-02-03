import '../lib/config/env.dart';
import '../lib/db/database.dart';

void main() async {
  print('Starting cleanup of MOCK PRODUCTS...');

  final db = AppDatabase();

  try {
    // 1. Delete dependent data first to satisfy Foreign Key constraints
    print('Deleting cart items...');
    await db.execute('DELETE FROM cart_items');

    print('Deleting favorites...');
    try {
      await db.execute('DELETE FROM favorites');
    } catch (_) {
      print('Skipping favorites (table might not exist)');
    }

    print('Deleting order items...');
    await db.execute('DELETE FROM order_items');

    print('Deleting reviews...');
    await db.execute('DELETE FROM reviews');

    // 2. Delete products
    print('Deleting products...');
    await db.execute('DELETE FROM products');

    // Optional: Delete orders as they are now empty
    print('Deleting orders...');
    await db.execute('DELETE FROM orders');

    print('✅ Mock products and related data cleared successfully!');
    print('Users and Stores have been PRESERVED.');
  } catch (e) {
    print('❌ Error clearing database: $e');
  } finally {
    await db.dispose();
  }
}
