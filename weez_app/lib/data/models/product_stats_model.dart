import '../../domain/entities/product_stats.dart';

class ProductStatsModel extends ProductStats {
  const ProductStatsModel({
    required super.sales,
    required super.rating,
    required super.reviews,
    required super.views,
  });

  factory ProductStatsModel.fromJson(Map<String, dynamic> json) {
    return ProductStatsModel(
      sales: json['sales'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] ?? 0,
      views: json['views'] ?? 0,
    );
  }
}
