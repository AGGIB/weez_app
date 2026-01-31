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
    print('Checking all products...');
    final result = await conn.execute(
      Sql.named('SELECT id, name, store_id FROM products'),
    );

    if (result.isEmpty) {
      print('No products found in DB.');
    } else {
      for (final row in result) {
        print('Product ID: ${row[0]}, Name: ${row[1]}, Store ID: ${row[2]}');
      }
    }

    print('\nChecking store for user agybaygibatollaev@gmail.com...');
    final userRes = await conn.execute(
      Sql.named('SELECT id FROM users WHERE email = @email'),
      parameters: {'email': 'agybaygibatollaev@gmail.com'},
    );
    if (userRes.isNotEmpty) {
      final userId = userRes.first[0];
      final storeRes = await conn.execute(
        Sql.named('SELECT id FROM stores WHERE seller_id = @id'),
        parameters: {'id': userId},
      );
      if (storeRes.isNotEmpty) {
        print('Store ID: ${storeRes.first[0]}');
      } else {
        print('Store not found for this user.');
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await conn.close();
  }
}
