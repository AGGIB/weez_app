import '../../domain/entities/product.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    required super.imageUrl,
    required super.rating,
    super.isFavorite,
    super.reviewsCount,
    super.imageUrls,
    super.discountPrice,
    super.deliveryInfo,
    super.sellerId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] ?? 'Uncategorized',
      imageUrl: json['imageUrl'],
      isFavorite: json['isFavorite'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] ?? 0,
      sellerId: json['sellerId']?.toString(),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      deliveryInfo: json['deliveryInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'sellerId': sellerId,
      'imageUrls': imageUrls,
      'discountPrice': discountPrice,
      'deliveryInfo': deliveryInfo,
    };
  }
}
