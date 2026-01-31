import 'package:equatable/equatable.dart';
import 'dart:io';
import '../../../domain/entities/store.dart';

abstract class SellerState extends Equatable {
  const SellerState();
  @override
  List<Object?> get props => [];
}

class SellerInitial extends SellerState {}

class SellerLoading extends SellerState {}

class SellerLoaded extends SellerState {
  final Store store;
  const SellerLoaded(this.store);
  @override
  List<Object?> get props => [store];
}

class SellerStoreEmpty extends SellerState {}

class SellerError extends SellerState {
  final String message;
  const SellerError(this.message);
  @override
  List<Object?> get props => [message];
}

abstract class SellerEvent extends Equatable {
  const SellerEvent();
  @override
  List<Object> get props => [];
}

class LoadSellerInfo extends SellerEvent {}

class CreateStore extends SellerEvent {
  final String name;
  final String description;
  final File? logo;

  const CreateStore({required this.name, required this.description, this.logo});
  @override
  List<Object> get props => [name, description, logo ?? ''];
}

class UpdateStore extends SellerEvent {
  final String name;
  final String description;
  final File? logo;

  const UpdateStore({required this.name, required this.description, this.logo});
  @override
  List<Object> get props => [name, description, logo ?? ''];
}
