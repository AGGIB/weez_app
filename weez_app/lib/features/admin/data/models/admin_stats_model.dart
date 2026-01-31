import '../../domain/entities/admin_stats.dart';

class AdminStatsModel extends AdminStats {
  const AdminStatsModel({
    required super.totalUsers,
    required super.totalStores,
    required super.totalOrders,
    required super.platformRevenue,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['total_users'] as int? ?? 0,
      totalStores: json['total_stores'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      platformRevenue: (json['platform_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
