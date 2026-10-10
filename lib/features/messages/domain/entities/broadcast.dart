import 'package:equatable/equatable.dart';

class Broadcast extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime sentAt;

  const Broadcast({required this.id, required this.title, required this.body, required this.sentAt});

  @override
  List<Object?> get props => [id, title, body, sentAt];
}
