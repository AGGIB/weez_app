import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../datasources/remote/ai_remote_datasource.dart';

abstract class AiRepository {
  Future<Either<Failure, String>> chat(List<Map<String, String>> messages);
}

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;

  AiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> chat(
    List<Map<String, String>> messages,
  ) async {
    try {
      final response = await remoteDataSource.chat(messages);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
