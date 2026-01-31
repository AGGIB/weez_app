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
  const LoadProducts({this.category, this.storeId});

  @override
  List<Object> get props => [category ?? '', storeId ?? ''];
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
