import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_stats.dart';
import '../../../domain/entities/review.dart';
import '../../../domain/repositories/product_repository.dart';

// Events
abstract class ProductStatsEvent extends Equatable {
  const ProductStatsEvent();
}

class LoadProductStats extends ProductStatsEvent {
  final String productId;
  const LoadProductStats(this.productId);
  @override
  List<Object> get props => [productId];
}

// States
abstract class ProductStatsState extends Equatable {
  const ProductStatsState();
}

class ProductStatsInitial extends ProductStatsState {
  @override
  List<Object> get props => [];
}

class ProductStatsLoading extends ProductStatsState {
  @override
  List<Object> get props => [];
}

class ProductStatsLoaded extends ProductStatsState {
  final ProductStats stats;
  final List<Review> reviews;

  const ProductStatsLoaded({required this.stats, required this.reviews});

  @override
  List<Object> get props => [stats, reviews];
}

class ProductStatsError extends ProductStatsState {
  final String message;
  const ProductStatsError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class ProductStatsBloc extends Bloc<ProductStatsEvent, ProductStatsState> {
  final ProductRepository productRepository;

  ProductStatsBloc({required this.productRepository})
    : super(ProductStatsInitial()) {
    on<LoadProductStats>((event, emit) async {
      emit(ProductStatsLoading());

      final statsResult = await productRepository.getProductStats(
        event.productId,
      );

      await statsResult.fold(
        (failure) async => emit(ProductStatsError(failure.message)),
        (stats) async {
          // If stats loaded successfully, load reviews
          final reviewsResult = await productRepository.getProductReviews(
            event.productId,
          );
          reviewsResult.fold(
            (failure) => emit(
              ProductStatsLoaded(stats: stats, reviews: []),
            ), // Partial success
            (reviews) =>
                emit(ProductStatsLoaded(stats: stats, reviews: reviews)),
          );
        },
      );
    });
  }
}
