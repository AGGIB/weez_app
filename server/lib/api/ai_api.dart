import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/ai_service.dart';

class AiApi {
  final AiService _aiService;

  AiApi() : _aiService = AiService();

  Router get router {
    final router = Router();
    router.post('/generate-description', _generateDescription);
    return router;
  }

  Future<Response> _generateDescription(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

      final productName = data['productName'];
      final category = data['category'];
      final keywords =
          (data['keywords'] as List<dynamic>?)?.cast<String>() ?? [];

      if (productName == null || category == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Missing required fields'}),
        );
      }

      final generatedText = await _aiService.generateDescription(
        productName: productName,
        category: category,
        keywords: keywords,
      );

      return Response.ok(
        json.encode({'generatedText': generatedText}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('AI Controller Error: $e');
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }
}
