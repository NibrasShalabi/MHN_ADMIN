import 'package:equatable/equatable.dart';

class SuggestionMessage extends Equatable {
  final String id;
  final String suggestionId;
  final String text;
  final DateTime sentAt;

  const SuggestionMessage({
    required this.id,
    required this.suggestionId,
    required this.text,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [id, suggestionId, text, sentAt];
}