import 'package:equatable/equatable.dart';

class AdminStats extends Equatable {
  final int totalUsers;
  final int totalStores;
  final int totalOrders;
  final double platformRevenue;

  const AdminStats({
    required this.totalUsers,
    required this.totalStores,
    required this.totalOrders,
    required this.platformRevenue,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    totalStores,
    totalOrders,
    platformRevenue,
  ];
}
