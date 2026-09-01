import 'package:equatable/equatable.dart';

import '../../domain/entities/product_suggestion.dart';

enum SuggestionsStatus { initial, loading, loaded, error }

class SuggestionsState extends Equatable {
  final SuggestionsStatus status;
  final List<ProductSuggestion> suggestions;
  final String? errorMessage;

  const SuggestionsState({
    this.status = SuggestionsStatus.initial,
    this.suggestions = const [],
    this.errorMessage,
  });

  SuggestionsState copyWith({
    SuggestionsStatus? status,
    List<ProductSuggestion>? suggestions,
    String? errorMessage,
  }) {
    return SuggestionsState(
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, suggestions, errorMessage];
}