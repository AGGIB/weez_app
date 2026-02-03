import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import '../lib/api/auth_api.dart';
import '../lib/api/product_api.dart';
import '../lib/api/seller_api.dart';
import '../lib/api/file_api.dart';
import '../lib/api/order_api.dart';
import '../lib/api/ai_api.dart';
import '../lib/api/cart_api.dart';
import '../lib/api/admin_api.dart';
import '../lib/middleware/cors.dart';
import '../lib/db/database.dart';
import '../lib/config/env.dart';
import '../lib/services/storage_service.dart';

// Configure routes.
final _router = Router()
  ..mount('/', AuthApi().router.call)
  ..mount('/', ProductApi().router.call)
  ..mount('/', SellerApi().router.call)
  ..mount('/', OrderApi().router.call)
  ..mount('/', FileApi().router.call)
  ..mount('/', AiApi().router.call)
  ..mount('/', CartApi().router.call)
  ..mount('/', AdminApi().router.call)
  ..get('/', _rootHandler);

Response _rootHandler(Request req) {
  return Response.ok('WEEZ Server is running\n');
}

void main(List<String> args) async {
  // Initialize Database
  final env = EnvConfig();
  print('Connecting to DB at ${env.dbHost}:${env.dbPort}');
  await db.ensureInitialized();
  // Initialize Storage
  await storage.ensureInitialized();

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
