import 'package:equatable/equatable.dart';

class AppReview extends Equatable {
  final String uid;
  final int stars;
  final String? comment;
  final DateTime createdAt;
  final bool isVisible;

  const AppReview({
    required this.uid,
    required this.stars,
    this.comment,
    required this.createdAt,
    required this.isVisible,
  });

  @override
  List<Object?> get props => [uid, stars, comment, createdAt, isVisible];
}