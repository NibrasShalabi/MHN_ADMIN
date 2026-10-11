import 'package:equatable/equatable.dart';

import '../../domain/entities/product_suggestion.dart';

enum SuggestionsStatus { initial, loading, loaded, error }

class SuggestionsState extends Equatable {
  final SuggestionsStatus status;
  final List<ProductSuggestion> suggestions;
  final String? errorMessage;

  /// The last page was full, so older entries may exist.
  final bool hasMore;
  final bool loadingMore;

  const SuggestionsState({
    this.status = SuggestionsStatus.initial,
    this.suggestions = const [],
    this.errorMessage,
    this.hasMore = false,
    this.loadingMore = false,
  });

  SuggestionsState copyWith({
    SuggestionsStatus? status,
    List<ProductSuggestion>? suggestions,
    String? errorMessage,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return SuggestionsState(
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  @override
  List<Object?> get props => [status, suggestions, errorMessage, hasMore, loadingMore];
}