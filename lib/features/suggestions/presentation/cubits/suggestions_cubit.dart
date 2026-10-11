import '../../../../core/bloc/safe_cubit.dart';

import '../../data/repository/firebase_admin_suggestions_repository.dart';
import '../../data/repository/suggestions_repository.dart';
import '../../domain/entities/product_suggestion.dart';
import 'suggestions_state.dart';
import '../../../../core/error/admin_error.dart';

class SuggestionsCubit extends SafeCubit<SuggestionsState> {
  final SuggestionsRepository _repository;

  SuggestionsCubit(this._repository) : super(const SuggestionsState());

  Future<void> loadSuggestions() async {
    emit(state.copyWith(status: SuggestionsStatus.loading));
    try {
      final suggestions = await _repository.getSuggestions();
      emit(state.copyWith(
        status: SuggestionsStatus.loaded,
        suggestions: suggestions,
        hasMore: suggestions.length == FirebaseAdminSuggestionsRepository.pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(status: SuggestionsStatus.error, errorMessage: AdminError.message(e)));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.suggestions.isEmpty) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final more = await _repository.getSuggestions(before: state.suggestions.last.createdAt);
      emit(state.copyWith(
        suggestions: [...state.suggestions, ...more],
        hasMore: more.length == FirebaseAdminSuggestionsRepository.pageSize,
        loadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(loadingMore: false, errorMessage: AdminError.message(e)));
    }
  }

  // Writes patch the list locally — reloading after each click re-read every suggestion.
  Future<void> approve(String id) => _write(() => _repository.approve(id), id, SuggestionStatus.approved);

  Future<void> reject(String id, String reason) =>
      _write(() => _repository.reject(id, reason), id, SuggestionStatus.rejected);

  Future<void> _write(Future<void> Function() action, String id, SuggestionStatus status) async {
    try {
      await action();
      emit(state.copyWith(suggestions: [
        for (final s in state.suggestions) s.id == id ? s.copyWith(status: status) : s,
      ]));
    } catch (e) {
      emit(state.copyWith(errorMessage: AdminError.message(e)));
    }
  }
}