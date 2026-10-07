import 'package:equatable/equatable.dart';

enum SupportTopic { complaint, suggestion, bug, other }

enum SupportStatus { open, resolved }

class SupportMessage extends Equatable {
  final String id;
  final String userId;
  final String sentBy;
  final SupportTopic topic;
  final String body;
  final SupportStatus status;
  final DateTime createdAt;
  final String? reply;

  const SupportMessage({
    required this.id,
    required this.userId,
    required this.sentBy,
    required this.topic,
    required this.body,
    required this.status,
    required this.createdAt,
    this.reply,
  });

  SupportMessage copyWith({String? sentBy, SupportStatus? status, String? reply}) => SupportMessage(
    id: id,
    userId: userId,
    sentBy: sentBy ?? this.sentBy,
    topic: topic,
    body: body,
    status: status ?? this.status,
    createdAt: createdAt,
    reply: reply ?? this.reply,
  );

  @override
  List<Object?> get props => [id, userId, sentBy, topic, body, status, createdAt, reply];
}