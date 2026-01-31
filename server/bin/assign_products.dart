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
    print('Assigning seeded products (ID 1-5) to Store 1...');
    final result = await conn.execute(
      Sql.named('UPDATE products SET store_id = 1 WHERE id <= 5'),
    );
    print('Affected rows: ${result.affectedRows}');

    // Also insure "айфон 17" (id 6) has all fields correct if needed.
    // print('Checking product 6...');
  } catch (e) {
    print('Error: $e');
  } finally {
    await conn.close();
  }
}
