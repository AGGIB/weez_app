import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/seller_repository.dart';
import 'seller_state_event.dart';

export 'seller_state_event.dart';

class SellerBloc extends Bloc<SellerEvent, SellerState> {
  final SellerRepository sellerRepository;

  SellerBloc({required this.sellerRepository}) : super(SellerInitial()) {
    on<LoadSellerInfo>(_onLoadSellerInfo);
    on<CreateStore>(_onCreateStore);
    on<UpdateStore>(_onUpdateStore);
  }

  Future<void> _onLoadSellerInfo(
    LoadSellerInfo event,
    Emitter<SellerState> emit,
  ) async {
    emit(SellerLoading());
    final result = await sellerRepository.getMyStore();
    result.fold((failure) {
      if (failure.message.contains('Store not found') ||
          failure.message.contains('404')) {
        emit(SellerStoreEmpty());
      } else {
        emit(SellerError(failure.message));
      }
    }, (store) => emit(SellerLoaded(store)));
  }

  Future<void> _onCreateStore(
    CreateStore event,
    Emitter<SellerState> emit,
  ) async {
    emit(SellerLoading());
    final result = await sellerRepository.createStore(
      event.name,
      event.description,
      event.logo,
    );
    result.fold(
      (failure) => emit(SellerError(failure.message)),
      (store) => emit(SellerLoaded(store)),
    );
  }

  Future<void> _onUpdateStore(
    UpdateStore event,
    Emitter<SellerState> emit,
  ) async {
    emit(SellerLoading());
    final result = await sellerRepository.updateStore(
      event.name,
      event.description,
      event.logo,
    );
    result.fold(
      (failure) => emit(SellerError(failure.message)),
      (store) => emit(SellerLoaded(store)),
    );
  }
}
