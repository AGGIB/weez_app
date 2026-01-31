import 'package:dartz/dartz.dart';
import 'dart:io'; // New import
import '../../core/error/failure.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/seller_repository.dart';
import '../datasources/remote/seller_remote_datasource.dart';

class SellerRepositoryImpl implements SellerRepository {
  final SellerRemoteDataSource remoteDataSource;

  SellerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Store>> getMyStore() async {
    return await remoteDataSource.getMyStore();
  }

  @override
  Future<Either<Failure, Store>> createStore(
    String name,
    String description,
    File? logo,
  ) async {
    return await remoteDataSource.createStore(name, description, logo);
  }

  @override
  Future<Either<Failure, String>> generateProductDescription(
    String productName,
    String category,
    List<String> keywords,
  ) async {
    return await remoteDataSource.generateProductDescription(
      productName,
      category,
      keywords,
    );
  }

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    return await remoteDataSource.getDashboardStats();
  }

  @override
  Future<Either<Failure, Store>> updateStore(
    String name,
    String description,
    File? logo,
  ) async {
    return await remoteDataSource.updateStore(name, description, logo);
  }
}
