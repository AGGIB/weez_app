import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/repositories/order_repository.dart';

// Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();
}

class LoadSellerOrders extends OrderEvent {
  @override
  List<Object> get props => [];
}

// States
abstract class OrderState extends Equatable {
  const OrderState();
}

class OrderInitial extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderLoading extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderLoaded extends OrderState {
  final List<OrderEntity> orders;
  const OrderLoaded(this.orders);
  @override
  List<Object> get props => [orders];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    on<LoadSellerOrders>((event, emit) async {
      emit(OrderLoading());
      final result = await orderRepository.getSellerOrders();
      result.fold(
        (failure) => emit(OrderError(failure.message)),
        (orders) => emit(OrderLoaded(orders)),
      );
    });
  }
}
