import 'dart:typed_data';
import 'dart:convert';
import 'package:minio_new/minio.dart';
import '../config/env.dart';

class StorageService {
  late final Minio _minio;
  final String bucket;

  StorageService() : bucket = EnvConfig().minioBucket {
    final env = EnvConfig();
    final uri = Uri.parse(env.minioEndpoint); // http://127.0.0.1:9000

    _minio = Minio(
      endPoint: uri.host,
      port: uri.port,
      useSSL: uri.scheme == 'https',
      accessKey: env.minioAccessKey,
      secretKey: env.minioSecretKey,
    );
  }

  Future<void> ensureInitialized() async {
    if (!await _minio.bucketExists(bucket)) {
      await _minio.makeBucket(bucket);
      // Set policy to public read?
      // For simplicity, we assume generic read access or generate presigned URLs.
      // But user wanted "Public Url".
      final policy =
          '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":["*"]},"Action":["s3:GetObject"],"Resource":["arn:aws:s3:::$bucket/*"]}]}';
      await _minio.setBucketPolicy(bucket, json.decode(policy));
    }
  }

  Future<String> uploadFile(
    String fileName,
    List<int> bytes,
    String contentType,
  ) async {
    await _minio.putObject(
      bucket,
      fileName,
      Stream.value(Uint8List.fromList(bytes)),
      size: bytes.length,
      metadata: {'content-type': contentType},
    );

    // Return accessible URL
    final env = EnvConfig();
    // Use localhost for emulator/simulator access if mapped ports match
    // Or use the minioEndpoint from env.
    // If running inside docker, minioEndpoint is 'minio:9000'.
    // But mobile app needs 'localhost:9000' (mapped).
    // Construct public URL manually for now.
    return 'http://localhost:9000/$bucket/$fileName';
  }
}

final storage = StorageService();
