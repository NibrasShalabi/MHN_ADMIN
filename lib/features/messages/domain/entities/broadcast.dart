import 'package:equatable/equatable.dart';

class Broadcast extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime sentAt;

  /// Also shown to customers who sign up after it was sent.
  final bool forNewCustomers;

  const Broadcast({required this.id, required this.title, required this.body, required this.sentAt, this.forNewCustomers = false});

  @override
  List<Object?> get props => [id, title, body, sentAt, forNewCustomers];
}
