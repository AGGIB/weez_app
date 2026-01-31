import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_stats.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminStatsLoading extends AdminState {}

class AdminStatsLoaded extends AdminState {
  final AdminStats stats;
  const AdminStatsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class AdminStatsError extends AdminState {
  final String message;
  const AdminStatsError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminUsersLoading extends AdminState {}

class AdminUsersLoaded extends AdminState {
  final List<dynamic> users;
  final int total;
  final int page;

  const AdminUsersLoaded({
    required this.users,
    required this.total,
    required this.page,
  });

  @override
  List<Object?> get props => [users, total, page];
}

class AdminUsersError extends AdminState {
  final String message;
  const AdminUsersError(this.message);
  @override
  List<Object?> get props => [message];
}

abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object> get props => [];
}

class LoadAdminStats extends AdminEvent {}

class LoadAdminUsers extends AdminEvent {
  final int page;
  final int limit;

  const LoadAdminUsers({this.page = 1, this.limit = 10});

  @override
  List<Object> get props => [page, limit];
}
