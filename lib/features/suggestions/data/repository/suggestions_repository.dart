import '../../domain/entities/product_suggestion.dart';

abstract class SuggestionsRepository {
  /// Newest first, one page at a time; [before] continues the list.
  Future<List<ProductSuggestion>> getSuggestions({DateTime? before});
  Future<void> approve(String id);
  Future<void> reject(String id, String reason);
}