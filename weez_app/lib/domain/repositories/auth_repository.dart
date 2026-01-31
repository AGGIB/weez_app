import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
    String role, {
    String? storeName,
    String? bin,
    String? address,
    String? phone,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, void>> resetPassword(String email);
}
