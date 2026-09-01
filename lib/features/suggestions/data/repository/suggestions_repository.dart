import '../../domain/entities/product_suggestion.dart';

abstract class SuggestionsRepository {
  Future<List<ProductSuggestion>> getSuggestions();
  Future<void> approve(String id);
  Future<void> reject(String id, String reason);
}