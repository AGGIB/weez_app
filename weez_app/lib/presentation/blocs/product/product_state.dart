import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  final List<String> categories;
  final String selectedCategory;

  const ProductLoaded({
    required this.products,
    required this.categories,
    required this.selectedCategory,
  });

  @override
  List<Object?> get props => [products, categories, selectedCategory];
}

class ProductFavoritesLoaded extends ProductState {
    final List<ProductEntity> favorites;

    const ProductFavoritesLoaded(this.favorites);

    @override
    List<Object?> get props => [favorites];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
