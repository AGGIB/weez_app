import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/form_data.dart';
import 'package:mime/mime.dart';
import '../services/storage_service.dart';

class FileApi {
  Router get router {
    final router = Router();
    router.post('/upload', _uploadImage);
    return router;
  }

  Future<Response> _uploadImage(Request request) async {
    if (!request.isMultipartForm) {
      return Response.badRequest(body: 'Not a multipart request');
    }

    try {
      final parameters = <String, String>{};
      await for (final formData in request.multipartFormData) {
        if (formData.part.headers.containsKey('content-disposition')) {
          // Not using fields for now, just looking for file
        }

        final name = formData.name;
        final filename = formData.filename;

        if (filename != null) {
          // It's a file
          final bytes = await formData.part.readBytes();
          final mimeType =
              lookupMimeType(filename) ?? 'application/octet-stream';

          // Generate unique name? Or use original for now + timestamp
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final storedFilename = '${timestamp}_$filename';

          final url = await storage.uploadFile(storedFilename, bytes, mimeType);

          return Response.ok(
            json.encode({'imageUrl': url}),
            headers: {'content-type': 'application/json'},
          );
        }
      }

      return Response.badRequest(body: 'No file found in request');
    } catch (e) {
      print('Upload error: $e');
      return Response.internalServerError(body: 'Upload failed');
    }
  }
}
