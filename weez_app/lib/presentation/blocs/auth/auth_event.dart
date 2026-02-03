import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? storeName;
  final String? bin;
  final String? address;
  final String? phone;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    this.role = 'buyer',
    this.storeName,
    this.bin,
    this.address,
    this.phone,
  });

  @override
  List<Object> get props => [name, email, password, role];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? email;
  final String? phone;

  const AuthUpdateProfileRequested({this.name, this.email, this.phone});

  @override
  List<Object> get props => [name ?? '', email ?? '', phone ?? ''];
}
