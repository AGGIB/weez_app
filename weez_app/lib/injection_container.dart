import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/cart_repository.dart';
import 'core/network/api_client.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/product_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/mock_cart_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/product/product_bloc.dart';
import 'presentation/blocs/product_stats/product_stats_bloc.dart';
import 'presentation/blocs/order/order_bloc.dart';
import 'presentation/blocs/order/order_details_bloc.dart';
import 'domain/repositories/order_repository.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/datasources/remote/order_remote_datasource.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'data/repositories/file_repository.dart';
import 'data/datasources/remote/seller_remote_datasource.dart';
import 'domain/repositories/seller_repository.dart';
import 'data/repositories/seller_repository_impl.dart';
import 'presentation/blocs/seller/seller_bloc.dart';
import 'presentation/blocs/seller_dashboard/seller_dashboard_bloc.dart';

// Admin
import 'features/admin/data/datasources/admin_remote_datasource.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/presentation/blocs/admin_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());

  //! Blocs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => ProductBloc(productRepository: sl()));
  sl.registerFactory(() => CartBloc(cartRepository: sl()));

  // Admin Bloc
  sl.registerFactory(() => AdminBloc(adminRepository: sl()));

  //! Repositories
  //! Core
  sl.registerLazySingleton(() => ApiClient(dio: sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () =>
        MockCartRepository(sl()), // Using MockCartRepository as Impl is missing
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SellerRepository>(
    () => SellerRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FileRepository>(
    () => FileRepositoryImpl(apiClient: sl()),
  );
  // AiRepository is missing, skipping for now.

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<SellerRemoteDataSource>(
    () => SellerRemoteDataSourceImpl(apiClient: sl()),
  );
  // FileRemoteDataSource is not used by FileRepositoryImpl (it uses ApiClient directly)
  // AiRemoteDataSource is missing/unused.

  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(apiClient: sl()),
  );

  // More Blocs
  sl.registerFactory(() => ProductStatsBloc(productRepository: sl()));
  sl.registerFactory(() => OrderBloc(orderRepository: sl()));
  sl.registerFactory(() => OrderDetailsBloc(orderRepository: sl()));
  sl.registerFactory(() => SellerBloc(sellerRepository: sl()));
  sl.registerFactory(() => SellerDashboardBloc(sellerRepository: sl()));
}
