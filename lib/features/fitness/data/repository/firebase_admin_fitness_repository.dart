import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/dynamic_form_field.dart';
import '../../domain/entities/fitness_submission.dart';
import '../../domain/entities/health_program.dart';
import 'fitness_repository.dart';

class FirebaseAdminFitnessRepository implements FitnessRepository {
  final FirebaseFirestore _db;

  FirebaseAdminFitnessRepository(this._db);

  @override
  Future<List<HealthProgram>> getPrograms() async {
    final snap = await _db.collection('fitnessPrograms').orderBy('order').get();
    return snap.docs.map(_programFromDoc).toList();
  }

  @override
  Future<void> addProgram(HealthProgram program) async {
    await _db.collection('fitnessPrograms').doc(program.id).set(_programToMap(program));
  }

  @override
  Future<void> updateProgram(HealthProgram program) async {
    await _db.collection('fitnessPrograms').doc(program.id).update(_programToMap(program));
  }

  @override
  Future<void> deleteProgram(String id) async {
    await _db.collection('fitnessPrograms').doc(id).delete();
  }

  @override
  Future<List<FitnessSubmission>> getSubmissions() async {
    final snap = await _db
        .collectionGroup('submissions')
        .get();
    return snap.docs.map(_submissionFromDoc).toList();
  }

  // ===== Mappers =====

  HealthProgram _programFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return HealthProgram(
      id: doc.id,
      title: d['title'] as String? ?? '',
      intro: d['intro'] as String? ?? '',
      coachWhatsappUrl: d['coachWhatsappUrl'] as String? ?? '',
      suggestedProgramIds: List<String>.from(d['suggestedPrograms'] as List? ?? []),
      fields: (d['fields'] as List<dynamic>? ?? []).map(_fieldFromMap).toList(),
    );
  }

  Map<String, dynamic> _programToMap(HealthProgram p) => {
    'title': p.title,
    'intro': p.intro,
    'coachWhatsappUrl': p.coachWhatsappUrl,
    'suggestedPrograms': p.suggestedProgramIds,
    'fields': p.fields.map((f) => {
      'id': f.id,
      'label': f.label,
      'type': f.type.name,
      'isRequired': f.isRequired,
      'options': f.options,
      'hint': f.hint,
    }).toList(),
  };

  DynamicFormField _fieldFromMap(dynamic map) {
    final m = map as Map<String, dynamic>;
    return DynamicFormField(
      id: m['id'] as String? ?? '',
      label: m['label'] as String? ?? '',
      type: FormFieldType.values.firstWhere(
            (t) => t.name == (m['type'] as String? ?? 'text'),
        orElse: () => FormFieldType.text,
      ),
      isRequired: m['isRequired'] as bool? ?? false,
      options: List<String>.from(m['options'] as List? ?? []),
      hint: m['hint'] as String?,
    );
  }

  FitnessSubmission _submissionFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return FitnessSubmission(
      id: doc.id,
      programId: d['programId'] as String? ?? '',
      programTitle: d['programTitle'] as String? ?? '',
      submittedByName: d['submittedByName'] as String? ?? '',
      submittedByWhatsapp: d['submittedByWhatsapp'] as String? ?? '',
      answers: Map<String, dynamic>.from(d['answers'] as Map? ?? {}),
      submittedAt: (d['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}