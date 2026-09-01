import '../../domain/entities/dynamic_form_field.dart';
import '../../domain/entities/fitness_submission.dart';
import '../../domain/entities/health_program.dart';
import 'fitness_repository.dart';

class FakeFitnessRepository implements FitnessRepository {
  final List<HealthProgram> _programs = [
    const HealthProgram(
      id: 'HP-1',
      title: 'إدارة الجسم',
      intro: 'برنامج مخصص لإدارة الوزن والتغذية.',
      coachWhatsappUrl: 'https://wa.me/963900000000',
      fields: [
        DynamicFormField(id: 'age', label: 'العمر', type: FormFieldType.number, isRequired: true),
        DynamicFormField(id: 'weight', label: 'الوزن', type: FormFieldType.number, isRequired: true),
      ],
    ),
  ];

  final List<FitnessSubmission> _submissions = [
    FitnessSubmission(
      id: 'SUB-1',
      programId: 'HP-1',
      programTitle: 'إدارة الجسم',
      submittedByName: 'م. س.',
      submittedByWhatsapp: 'https://wa.me/963911111111',
      answers: const {'age': '27', 'weight': '65'},
      submittedAt: DateTime(2026, 8, 24),
    ),
  ];

  @override
  Future<List<HealthProgram>> getPrograms() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_programs);
  }

  @override
  Future<void> addProgram(HealthProgram program) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _programs.add(program);
  }

  @override
  Future<void> updateProgram(HealthProgram program) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _programs.indexWhere((p) => p.id == program.id);
    if (index != -1) _programs[index] = program;
  }

  @override
  Future<void> deleteProgram(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _programs.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<FitnessSubmission>> getSubmissions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_submissions);
  }
}