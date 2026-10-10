import '../../../../core/bloc/safe_cubit.dart';
import '../../data/repository/fitness_repository.dart';
import '../../domain/entities/fitness_section.dart';
import '../../domain/entities/health_program.dart';
import 'programs_state.dart';

class ProgramsCubit extends SafeCubit<ProgramsState> {
  final FitnessRepository _repository;

  ProgramsCubit(this._repository) : super(const ProgramsState());

  /// Always the four sections (saved or still empty), then anything saved
  /// under another id — older programs the app no longer shows.
  Future<void> loadPrograms() async {
    emit(state.copyWith(status: ProgramsStatus.loading));
    try {
      final saved = {for (final p in await _repository.getPrograms()) p.id: p};
      emit(state.copyWith(status: ProgramsStatus.loaded, programs: [
        for (final s in FitnessSection.values) saved.remove(s.id) ?? s.empty,
        ...saved.values,
      ]));
    } catch (e) {
      emit(state.copyWith(status: ProgramsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> saveProgram(HealthProgram program) async {
    try {
      await _repository.saveProgram(program, order: FitnessSection.byId(program.id)?.index ?? 99);
      await loadPrograms();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> deleteProgram(String id) async {
    try {
      await _repository.deleteProgram(id);
      await loadPrograms();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
