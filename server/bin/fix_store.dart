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
    print('Checking user...');
    final result = await conn.execute(
      Sql.named('SELECT id, role FROM users WHERE email = @email'),
      parameters: {'email': 'agybaygibatollaev@gmail.com'},
    );

    if (result.isEmpty) {
      print('User not found!');
      return;
    }

    final row = result.first;
    final userId = row[0] as int;
    final role = row[1] as String?;

    print('User found: ID=$userId, Role=$role');

    if (role != 'seller') {
      print('Updating role to seller...');
      await conn.execute(
        Sql.named("UPDATE users SET role = 'seller' WHERE id = @id"),
        parameters: {'id': userId},
      );
    }

    print('Checking store...');
    final storeResult = await conn.execute(
      Sql.named('SELECT id FROM stores WHERE seller_id = @id'),
      parameters: {'id': userId},
    );

    if (storeResult.isEmpty) {
      print('Store not found. Creating default store...');
      await conn.execute(
        Sql.named(
          'INSERT INTO stores (seller_id, name, description, legal_info) VALUES (@id, @name, @desc, @legal)',
        ),
        parameters: {
          'id': userId,
          'name': 'My Awesome Store',
          'desc': 'Default store description',
          'legal': 'Legal info here',
        },
      );
      print('Store created successfully!');
    } else {
      print('Store already exists (ID: ${storeResult.first[0]}).');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await conn.close();
  }
}
