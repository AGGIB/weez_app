import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userName, rating, comment, createdAt];
}
