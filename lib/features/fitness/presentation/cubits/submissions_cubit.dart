import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/fitness_repository.dart';
import 'submissions_state.dart';

class SubmissionsCubit extends Cubit<SubmissionsState> {
  final FitnessRepository _repository;

  SubmissionsCubit(this._repository) : super(const SubmissionsState());

  Future<void> loadSubmissions() async {
    emit(state.copyWith(status: SubmissionsStatus.loading));
    try {
      final submissions = await _repository.getSubmissions();
      emit(state.copyWith(status: SubmissionsStatus.loaded, submissions: submissions));
    } catch (e) {
      emit(state.copyWith(status: SubmissionsStatus.error, errorMessage: e.toString()));
    }
  }
}