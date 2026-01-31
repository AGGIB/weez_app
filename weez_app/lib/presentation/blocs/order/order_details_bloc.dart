import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/repositories/order_repository.dart';

// Events
abstract class OrderDetailsEvent extends Equatable {
  const OrderDetailsEvent();
}

class LoadOrderDetails extends OrderDetailsEvent {
  final String id;
  const LoadOrderDetails(this.id);
  @override
  List<Object> get props => [id];
}

class UpdateOrderStatus extends OrderDetailsEvent {
  final String id;
  final String status;
  const UpdateOrderStatus(this.id, this.status);
  @override
  List<Object> get props => [id, status];
}

// States
abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();
}

class OrderDetailsInitial extends OrderDetailsState {
  @override
  List<Object> get props => [];
}

class OrderDetailsLoading extends OrderDetailsState {
  @override
  List<Object> get props => [];
}

class OrderDetailsLoaded extends OrderDetailsState {
  final OrderEntity order;
  const OrderDetailsLoaded(this.order);
  @override
  List<Object> get props => [order];
}

class OrderStatusUpdating extends OrderDetailsState {
  @override
  List<Object> get props => [];
}

class OrderStatusUpdateSuccess extends OrderDetailsState {
  @override
  List<Object> get props => [];
}

class OrderDetailsError extends OrderDetailsState {
  final String message;
  const OrderDetailsError(this.message);
  @override
  List<Object> get props => [message];
}

class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  final OrderRepository orderRepository;

  OrderDetailsBloc({required this.orderRepository})
    : super(OrderDetailsInitial()) {
    on<LoadOrderDetails>((event, emit) async {
      emit(OrderDetailsLoading());
      final result = await orderRepository.getOrderDetails(event.id);
      result.fold(
        (failure) => emit(OrderDetailsError(failure.message)),
        (order) => emit(OrderDetailsLoaded(order)),
      );
    });

    on<UpdateOrderStatus>((event, emit) async {
      // Keep showing details if loaded?
      // Or switch to updating state?
      // Better: emit Loading/Updating, then Success, then reload?
      // For simplicity, emit Updating.
      emit(OrderStatusUpdating());
      final result = await orderRepository.updateOrderStatus(
        event.id,
        event.status,
      );
      result.fold((failure) => emit(OrderDetailsError(failure.message)), (_) {
        emit(OrderStatusUpdateSuccess());
        // Ideally reload details after success
        add(LoadOrderDetails(event.id));
      });
    });
  }
}
