import 'package:equatable/equatable.dart';
import '../../../../domain/entities/dashboard_stats.dart';

abstract class SellerDashboardEvent extends Equatable {
  const SellerDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardStats extends SellerDashboardEvent {}

abstract class SellerDashboardState extends Equatable {
  const SellerDashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardStatsLoading extends SellerDashboardState {}

class DashboardStatsLoaded extends SellerDashboardState {
  final DashboardStats stats;

  const DashboardStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class DashboardStatsError extends SellerDashboardState {
  final String message;

  const DashboardStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
