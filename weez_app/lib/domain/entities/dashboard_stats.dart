import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final double totalRevenue;
  final int ordersCount;
  final int productsCount;
  final double averageRating;

  const DashboardStats({
    required this.totalRevenue,
    required this.ordersCount,
    required this.productsCount,
    required this.averageRating,
  });

  @override
  List<Object?> get props => [
    totalRevenue,
    ordersCount,
    productsCount,
    averageRating,
  ];
}
