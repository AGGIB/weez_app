import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? legalInfo;
  final double rating;

  const Store({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.legalInfo,
    required this.rating,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    logoUrl,
    legalInfo,
    rating,
  ];
}
