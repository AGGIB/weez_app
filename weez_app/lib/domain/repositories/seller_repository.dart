import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/store.dart';
import '../entities/dashboard_stats.dart';

import 'dart:io';

abstract class SellerRepository {
  Future<Either<Failure, Store>> getMyStore();
  Future<Either<Failure, Store>> createStore(
    String name,
    String description,
    File? logo,
  );
  Future<Either<Failure, String>> generateProductDescription(
    String productName,
    String category,
    List<String> keywords,
  );
  Future<Either<Failure, DashboardStats>> getDashboardStats();
  Future<Either<Failure, Store>> updateStore(
    String name,
    String description,
    File? logo,
  );
}
