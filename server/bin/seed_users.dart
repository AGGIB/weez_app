import 'package:postgres/postgres.dart';
import '../lib/config/env.dart';
import '../lib/db/database.dart';
import '../lib/utils/hash.dart';

void main() async {
  print('Seeding users...');
  final env = EnvConfig();
  await db.ensureInitialized();

  final users = [
    {
      'email': 'admin@weez.com',
      'password': 'password123',
      'name': 'Admin User',
      'role': 'admin',
      'phone': '+1234567890',
    },
    {
      'email': 'seller@weez.com',
      'password': 'password123',
      'name': 'Seller User',
      'role': 'seller',
      'phone': '+1987654321',
      'store_name': 'Best Gadgets',
      'bin': '123456789012',
      'address': '123 Tech Street',
    },
    {
      'email': 'buyer@weez.com',
      'password': 'password123',
      'name': 'Buyer User',
      'role': 'buyer',
      'phone': '+1122334455',
    },
  ];

  for (var u in users) {
    try {
      // Check if user exists
      final check = await db.queryMapped(
        'SELECT id FROM users WHERE email = @email',
        substitutionValues: {'email': u['email']},
      );
      if (check.isNotEmpty) {
        print('User ${u['email']} already exists. Updating role/password...');
        await db.execute(
          'UPDATE users SET role = @role, password_hash = @pass WHERE email = @email',
          substitutionValues: {
            'role': u['role'],
            'pass': hashPassword(u['password'] as String),
            'email': u['email'],
          },
        );
      } else {
        print('Creating user ${u['email']}...');
        await db.execute(
          '''INSERT INTO users (email, password_hash, name, role, phone, store_name, bin, address) 
             VALUES (@email, @pass, @name, @role, @phone, @storeName, @bin, @address)''',
          substitutionValues: {
            'email': u['email'],
            'pass': hashPassword(u['password'] as String),
            'name': u['name'],
            'role': u['role'],
            'phone': u['phone'],
            'storeName': u['store_name'],
            'bin': u['bin'],
            'address': u['address'],
          },
        );

        // If seller, ensure store exists
        if (u['role'] == 'seller') {
          final userIdRes = await db.queryMapped(
            'SELECT id FROM users WHERE email = @email',
            substitutionValues: {'email': u['email']},
          );
          final userId = userIdRes.first['id'];

          final storeCheck = await db.queryMapped(
            'SELECT id FROM stores WHERE seller_id = @id',
            substitutionValues: {'id': userId},
          );
          if (storeCheck.isEmpty) {
            print('Creating store for ${u['email']}...');
            await db.execute(
              'INSERT INTO stores (seller_id, name, description) VALUES (@id, @name, @desc)',
              substitutionValues: {
                'id': userId,
                'name': u['store_name'],
                'desc': 'Description for ${u['store_name']}',
              },
            );
          }
        }
      }
    } catch (e) {
      print('Error seeding ${u['email']}: $e');
    }
  }

  print('Seeding complete.');
  // Wait a bit for async ops if any pending (though await should handle it)
  await Future.delayed(Duration(seconds: 1));
  await db.dispose();
}
