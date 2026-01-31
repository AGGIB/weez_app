import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/seller_repository.dart';
import 'seller_dashboard_state.dart';

class SellerDashboardBloc
    extends Bloc<SellerDashboardEvent, SellerDashboardState> {
  final SellerRepository sellerRepository;

  SellerDashboardBloc({required this.sellerRepository})
    : super(DashboardStatsLoading()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
  }

  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<SellerDashboardState> emit,
  ) async {
    emit(DashboardStatsLoading());
    final result = await sellerRepository.getDashboardStats();
    result.fold(
      (failure) => emit(DashboardStatsError(failure.message)),
      (stats) => emit(DashboardStatsLoaded(stats)),
    );
  }
}
