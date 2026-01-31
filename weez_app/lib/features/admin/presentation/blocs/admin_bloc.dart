import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_state_event.dart';

export 'admin_state_event.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository adminRepository;

  AdminBloc({required this.adminRepository}) : super(AdminInitial()) {
    on<LoadAdminStats>(_onLoadStats);
    on<LoadAdminUsers>(_onLoadUsers);
  }

  Future<void> _onLoadStats(
    LoadAdminStats event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminStatsLoading());
    final result = await adminRepository.getStats();
    result.fold(
      (failure) => emit(AdminStatsError(failure.message)),
      (stats) => emit(AdminStatsLoaded(stats)),
    );
  }

  Future<void> _onLoadUsers(
    LoadAdminUsers event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminUsersLoading());
    final result = await adminRepository.getUsers(
      page: event.page,
      limit: event.limit,
    );
    result.fold((failure) => emit(AdminUsersError(failure.message)), (data) {
      final users = data['data'] as List;
      final meta = data['meta'] as Map;
      emit(
        AdminUsersLoaded(
          users: users,
          total: meta['total'] as int,
          page: meta['page'] as int,
        ),
      );
    });
  }
}
