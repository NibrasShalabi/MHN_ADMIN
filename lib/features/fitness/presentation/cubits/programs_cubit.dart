import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/fitness_repository.dart';
import '../../domain/entities/health_program.dart';
import 'programs_state.dart';

class ProgramsCubit extends Cubit<ProgramsState> {
  final FitnessRepository _repository;

  ProgramsCubit(this._repository) : super(const ProgramsState());

  Future<void> loadPrograms() async {
    emit(state.copyWith(status: ProgramsStatus.loading));
    try {
      final programs = await _repository.getPrograms();
      emit(state.copyWith(status: ProgramsStatus.loaded, programs: programs));
    } catch (e) {
      emit(state.copyWith(status: ProgramsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> addProgram(HealthProgram program) async {
    await _repository.addProgram(program);
    await loadPrograms();
  }

  Future<void> updateProgram(HealthProgram program) async {
    await _repository.updateProgram(program);
    await loadPrograms();
  }

  Future<void> deleteProgram(String id) async {
    await _repository.deleteProgram(id);
    await loadPrograms();
  }
}