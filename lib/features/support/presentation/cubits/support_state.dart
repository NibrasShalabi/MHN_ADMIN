
import 'package:equatable/equatable.dart';

import '../../domain/entities/support_message.dart';

enum SupportPageStatus { initial, loading, loaded, error }

class SupportState extends Equatable {
  final SupportPageStatus status;
  final List<SupportMessage> messages;
  final String? errorMessage;

  const SupportState({
    this.status = SupportPageStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  SupportState copyWith({
    SupportPageStatus? status,
    List<SupportMessage>? messages,
    String? errorMessage,
  }) {
    return SupportState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage];
}