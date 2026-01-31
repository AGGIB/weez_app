import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalRevenue,
    required super.ordersCount,
    required super.productsCount,
    required super.averageRating,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      ordersCount: json['orders_count'] as int,
      productsCount: json['products_count'] as int,
      averageRating: (json['average_rating'] as num).toDouble(),
    );
  }
}
