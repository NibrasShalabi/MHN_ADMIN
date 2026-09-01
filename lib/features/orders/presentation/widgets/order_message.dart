import 'package:equatable/equatable.dart';

class OrderMessage extends Equatable {
  final String id;
  final String orderId;
  final String text;
  final DateTime sentAt;

  const OrderMessage({
    required this.id,
    required this.orderId,
    required this.text,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [id, orderId, text, sentAt];
}