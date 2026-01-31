import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../core/error/failure.dart';
import '../../core/network/api_client.dart';

abstract class FileRepository {
  Future<Either<Failure, String>> uploadImage(File file);
}

class FileRepositoryImpl implements FileRepository {
  final ApiClient apiClient;

  FileRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, String>> uploadImage(File file) async {
    try {
      final String fileName = file.path.split('/').last;

      // Basic mime type detection
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      final response = await apiClient.post('/files/upload', data: formData);

      if (response.statusCode == 200) {
        final data = response.data;
        // Expecting { "imageUrl": "..." }
        return Right(data['imageUrl']);
      } else {
        return Left(
          ServerFailure('Image upload failed: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error during upload'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
