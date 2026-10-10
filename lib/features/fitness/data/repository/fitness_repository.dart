import '../../domain/entities/fitness_submission.dart';
import '../../domain/entities/health_program.dart';

abstract class FitnessRepository {
  Future<List<HealthProgram>> getPrograms();
  Future<void> addProgram(HealthProgram program);
  Future<void> updateProgram(HealthProgram program);
  Future<void> deleteProgram(String id);

  /// Newest first, the latest [FirebaseAdminFitnessRepository.pageSize].
  Future<List<FitnessSubmission>> getSubmissions();

  /// Moves a request along; contacted/closed tell the customer.
  Future<void> updateStatus(FitnessSubmission submission, SubmissionStatus status);

  /// A written reply from the specialist, delivered to the customer's messages.
  Future<void> reply(FitnessSubmission submission, String text);

  /// The number customers reach from the supplements page and from
  /// consult-only products (config/fitness).
  Future<String> getSpecialistWhatsapp();
  Future<void> setSpecialistWhatsapp(String number);
}
