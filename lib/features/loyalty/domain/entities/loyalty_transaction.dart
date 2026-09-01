import 'package:equatable/equatable.dart';

class LoyaltyTransaction extends Equatable {
  final String id;
  final String userName;
  final String userPhone;
  final int points;
  final String reason;
  final String? reference;
  final DateTime createdAt;

  const LoyaltyTransaction({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.points,
    required this.reason,
    this.reference,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userName, userPhone, points, reason, reference, createdAt];
}