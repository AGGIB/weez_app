import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/repositories/order_repository.dart';

// States
abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final Map<String, dynamic> result;
  const CheckoutSuccess(this.result);
  @override
  List<Object> get props => [result];
}

class CheckoutFailure extends CheckoutState {
  final String message;
  const CheckoutFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class CheckoutCubit extends Cubit<CheckoutState> {
  final OrderRepository orderRepository;

  CheckoutCubit({required this.orderRepository}) : super(CheckoutInitial());

  Future<void> checkout() async {
    emit(CheckoutLoading());
    final result = await orderRepository.checkout();
    result.fold(
      (failure) => emit(CheckoutFailure(failure.message)),
      (data) => emit(CheckoutSuccess(data)),
    );
  }
}
