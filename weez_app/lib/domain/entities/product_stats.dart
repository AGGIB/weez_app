import 'package:equatable/equatable.dart';

class ProductStats extends Equatable {
  final int sales;
  final double rating;
  final int reviews;
  final int views;

  const ProductStats({
    required this.sales,
    required this.rating,
    required this.reviews,
    required this.views,
  });

  @override
  List<Object?> get props => [sales, rating, reviews, views];
}
