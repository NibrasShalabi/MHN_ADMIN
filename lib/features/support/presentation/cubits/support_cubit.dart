import '../../../../core/bloc/safe_cubit.dart';
import '../../data/repository/support_repository.dart';
import '../../domain/entities/support_message.dart';
import 'support_state.dart';

class SupportCubit extends SafeCubit<SupportState> {
  final SupportRepository _repository;

  SupportCubit(this._repository) : super(const SupportState());

  Future<void> loadMessages() async {
    emit(state.copyWith(status: SupportPageStatus.loading));
    try {
      final messages = await _repository.getMessages();
      emit(state.copyWith(status: SupportPageStatus.loaded, messages: messages));
    } catch (e) {
      emit(state.copyWith(status: SupportPageStatus.error, errorMessage: e.toString()));
    }
  }

  /// No reload after writing — the row is patched locally (0 reads).
  Future<void> resolve(SupportMessage message, {String? reply}) async {
    try {
      await _repository.resolve(message, reply: reply);
      emit(state.copyWith(messages: [
        for (final m in state.messages)
          m.id == message.id ? m.copyWith(status: SupportStatus.resolved, reply: reply) : m,
      ]));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}