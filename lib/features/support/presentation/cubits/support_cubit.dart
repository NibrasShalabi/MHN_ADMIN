import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/support_repository.dart';
import 'support_state.dart';

class SupportCubit extends Cubit<SupportState> {
  final SupportRepository _repository;

  SupportCubit(this._repository) : super(const SupportState());

  Future<void> loadMessages() async {
    if (isClosed) return;
    emit(state.copyWith(status: SupportPageStatus.loading));
    try {
      final messages = await _repository.getMessages();
      if (!isClosed) emit(state.copyWith(status: SupportPageStatus.loaded, messages: messages));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(status: SupportPageStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> markResolved(String id, {String? reply}) async {
    await _repository.markResolved(id, reply: reply);
    await loadMessages();
  }
}

