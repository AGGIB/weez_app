import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final bool isFavorite;
  final int reviewsCount;
  final String? sellerId;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    this.isFavorite = false,
    this.reviewsCount = 0,
    this.sellerId,
    this.imageUrls = const [],
    this.discountPrice,
    this.deliveryInfo,
  });

  final List<String> imageUrls;
  final double? discountPrice;
  final String? deliveryInfo;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    imageUrl,
    category,
    rating,
    isFavorite,
    reviewsCount,
    sellerId,
    imageUrls,
    discountPrice,
    deliveryInfo,
  ];
}
