import '../../domain/entities/store.dart';

class StoreModel extends Store {
  const StoreModel({
    required super.id,
    required super.name,
    required super.description,
    super.logoUrl,
    super.legalInfo,
    required super.rating,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'].toString(), // Ensure string
      name: json['name'],
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'],
      legalInfo: json['legalInfo'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'legalInfo': legalInfo,
      'rating': rating,
    };
  }
}
