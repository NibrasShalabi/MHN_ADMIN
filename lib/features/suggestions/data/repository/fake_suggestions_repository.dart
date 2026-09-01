import '../../domain/entities/product_suggestion.dart';
import '../../domain/entities/suggestion_message.dart';
import 'suggestions_repository.dart';

class FakeSuggestionsRepository implements SuggestionsRepository {
  final List<ProductSuggestion> _suggestions = [
    ProductSuggestion(
      id: 'S-1',
      suggestedBy: 'رهف عيسى',
      productName: 'كريم تفتيح للبشرة الدهنية',
      link: 'https://example.com/product/123',
      status: SuggestionStatus.underReview,
      createdAt: DateTime(2026, 8, 25),
    ),
  ];
  final List<SuggestionMessage> _messages = [];

  @override
  Future<List<ProductSuggestion>> getSuggestions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_suggestions);
  }

  @override
  Future<void> approve(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _suggestions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _suggestions[index] = _suggestions[index].copyWith(status: SuggestionStatus.approved);
    }
    _messages.add(SuggestionMessage(
      id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
      suggestionId: id,
      text: 'تم توفير المنتج الذي اقترحته',
      sentAt: DateTime.now(),
    ));
  }

  @override
  Future<void> reject(String id, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _suggestions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _suggestions[index] = _suggestions[index].copyWith(status: SuggestionStatus.rejected);
    }
    _messages.add(SuggestionMessage(
      id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
      suggestionId: id,
      text: reason,
      sentAt: DateTime.now(),
    ));
  }
}