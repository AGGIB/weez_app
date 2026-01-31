import 'dart:io';
import 'package:dotenv/dotenv.dart';

class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;

  final DotEnv _env = DotEnv(includePlatformEnvironment: true);

  EnvConfig._internal() {
    // Load .env file if it exists
    _env.load();
  }

  String get dbHost => _env['DB_HOST'] ?? 'localhost';
  int get dbPort => int.parse(_env['DB_PORT'] ?? '5432');
  String get dbName => _env['DB_NAME'] ?? 'weez_db';
  String get dbUser => _env['DB_USER'] ?? 'weez_user';
  String get dbPassword => _env['DB_PASSWORD'] ?? 'weez_password';

  String get minioEndpoint => _env['MINIO_ENDPOINT'] ?? 'http://localhost:9000';
  String get minioAccessKey => _env['MINIO_ACCESS_KEY'] ?? 'weez_minio';
  String get minioSecretKey =>
      _env['MINIO_SECRET_KEY'] ?? 'weez_minio_password';
  String get minioBucket => _env['MINIO_BUCKET'] ?? 'products';

  String get aiApiKey => _env['AI_API_KEY'] ?? '';
}
