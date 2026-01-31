import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/admin_stats.dart';
import '../../data/datasources/admin_remote_datasource.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminStats>> getStats();
  Future<Either<Failure, Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 10,
  });
}

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AdminStats>> getStats() async {
    return await remoteDataSource.getStats();
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 10,
  }) async {
    return await remoteDataSource.getUsers(page: page, limit: limit);
  }
}
