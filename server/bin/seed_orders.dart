import 'dart:io';
import 'package:postgres/postgres.dart';

void main() async {
  final conn = await Connection.open(
    Endpoint(
      host: '127.0.0.1',
      port: 5432,
      database: 'weez_db',
      username: 'weez_user',
      password: 'weez_password',
    ),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );

  try {
    print('Seeding orders for Store 1...');

    // 1. Create a few orders
    for (int i = 0; i < 3; i++) {
      final result = await conn.execute(
        Sql.named(
          'INSERT INTO orders (user_id, store_id, total_amount, status) VALUES (6, 1, @amount, @status) RETURNING id',
        ),
        parameters: {
          'amount': (i + 1) * 1000.0,
          'status': i == 0 ? 'pending' : (i == 1 ? 'shipped' : 'delivered'),
        },
      );
      final orderId = result.first[0];
      print('Created Order ID: $orderId');

      // 2. Add items to order
      await conn.execute(
        Sql.named(
          'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (@order_id, 6, 1, 999.0)',
        ),
        parameters: {'order_id': orderId},
      );
    }

    print('Seeded 3 orders successfully.');
  } catch (e) {
    print('Error: $e');
  } finally {
    await conn.close();
  }
}
