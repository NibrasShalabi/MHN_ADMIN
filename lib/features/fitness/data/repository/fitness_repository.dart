import '../../domain/entities/fitness_submission.dart';
import '../../domain/entities/health_program.dart';

abstract class FitnessRepository {
  Future<List<HealthProgram>> getPrograms();
  Future<void> addProgram(HealthProgram program);
  Future<void> updateProgram(HealthProgram program);
  Future<void> deleteProgram(String id);

  Future<List<FitnessSubmission>> getSubmissions();
}