import 'dart:io';
import '../lib/db/database.dart';
import '../lib/config/env.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run bin/make_admin.dart <email>');
    exit(1);
  }

  final email = args[0];
  final env = EnvConfig();
  print('Connecting to DB...');
  await db.ensureInitialized();

  try {
    // Check if user exists
    final result = await db.queryMapped(
      'SELECT id, name, role FROM users WHERE email = @email',
      substitutionValues: {'email': email},
    );

    if (result.isEmpty) {
      print('User with email $email not found.');
      exit(1);
    }

    final user = result.first;
    print('Found user: ${user['name']} (Current Role: ${user['role']})');

    // Update role
    await db.execute(
      "UPDATE users SET role = 'admin' WHERE email = @email",
      substitutionValues: {'email': email},
    );

    print('Successfully promoted $email to ADMIN.');
  } catch (e) {
    print('Error: $e');
  } finally {
    // exit(0); // db connection might keep alive, force exit?
    // Actually db pool might need closing but simple script can just finish.
    exit(0);
  }
}
