import '../../../../core/bloc/safe_cubit.dart';
import '../../data/repository/fitness_repository.dart';
import '../../domain/entities/fitness_submission.dart';
import 'submissions_state.dart';
import '../../../../core/error/admin_error.dart';

class SubmissionsCubit extends SafeCubit<SubmissionsState> {
  final FitnessRepository _repository;

  SubmissionsCubit(this._repository) : super(const SubmissionsState());

  Future<void> loadSubmissions() async {
    emit(state.copyWith(status: SubmissionsStatus.loading));
    try {
      final submissions = await _repository.getSubmissions();
      emit(state.copyWith(status: SubmissionsStatus.loaded, submissions: submissions));
    } catch (e) {
      emit(state.copyWith(status: SubmissionsStatus.error, errorMessage: AdminError.message(e)));
    }
  }

  Future<bool> setStatus(FitnessSubmission s, SubmissionStatus status) =>
      _write(() => _repository.updateStatus(s, status), s.withStatus(status));

  Future<bool> reply(FitnessSubmission s, String text) =>
      _write(() => _repository.reply(s, text), s.withStatus(SubmissionStatus.contacted));

  Future<bool> _write(Future<void> Function() action, FitnessSubmission updated) async {
    try {
      await action();
      emit(state.copyWith(
        submissions: [for (final s in state.submissions) s.path == updated.path ? updated : s],
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: AdminError.message(e)));
      return false;
    }
  }
}
