import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/suggestions_repository.dart';
import 'suggestions_state.dart';

class SuggestionsCubit extends Cubit<SuggestionsState> {
  final SuggestionsRepository _repository;

  SuggestionsCubit(this._repository) : super(const SuggestionsState());

  Future<void> loadSuggestions() async {
    emit(state.copyWith(status: SuggestionsStatus.loading));
    try {
      final suggestions = await _repository.getSuggestions();
      emit(state.copyWith(status: SuggestionsStatus.loaded, suggestions: suggestions));
    } catch (e) {
      emit(state.copyWith(status: SuggestionsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> approve(String id) async {
    await _repository.approve(id);
    await loadSuggestions();
  }

  Future<void> reject(String id, String reason) async {
    await _repository.reject(id, reason);
    await loadSuggestions();
  }
}