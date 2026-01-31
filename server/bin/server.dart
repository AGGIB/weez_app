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
import '../lib/api/admin_api.dart';
import '../lib/middleware/cors.dart';
import '../lib/db/database.dart';
import '../lib/config/env.dart';
import '../lib/services/storage_service.dart';

// Configure routes.
final _router = Router()
  ..mount('/auth', AuthApi().router.call)
  ..mount('/products', ProductApi().router.call)
  ..mount('/seller', SellerApi().router.call)
  ..mount(
    '/shop',
    OrderApi().router.call,
  ) // Mount as /shop/seller/orders is in OrderApi but accessed via /shop prefix? No, let's keep it simple.
  // OrderApi defines router.get('/seller/orders').
  // If I mount it at '/', then it is accessibility at /seller/orders.
  // But wait, SellerApi is mounted at /seller.
  // Let's mount OrderApi at / (root) so it captures /seller/orders?
  // Or better, move /seller/orders to /seller mount in SellerApi?
  // No, separate file is better.
  // I will mount OrderApi at /api/orders or just root if it has full paths.
  // OrderApi has: router.get('/seller/orders', ...)
  // If I mount at /shop, accessing it would be /shop/seller/orders.
  // Users request "Orders Menu".
  ..mount('/', OrderApi().router.call)
  ..mount('/files', FileApi().router.call)
  ..mount('/api/v1/ai', AiApi().router.call)
  ..mount('/api/v1/admin', AdminApi().router.call)
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
