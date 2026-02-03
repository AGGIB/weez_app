import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {
  final String? category;
  final String? storeId;
  final String? search;
  final double? minPrice;
  final double? maxPrice;

  const LoadProducts({
    this.category,
    this.storeId,
    this.search,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object> get props => [
    category ?? '',
    storeId ?? '',
    search ?? '',
    minPrice ?? 0,
    maxPrice ?? 0,
  ];
}

class SearchProducts extends ProductEvent {
  final String query;
  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}

class ToggleFavorite extends ProductEvent {
  final String productId;
  const ToggleFavorite(this.productId);

  @override
  List<Object> get props => [productId];
}

class LoadFavorites extends ProductEvent {}

class CreateProduct extends ProductEvent {
  final ProductEntity product;
  const CreateProduct(this.product);

  @override
  List<Object> get props => [product];
}
