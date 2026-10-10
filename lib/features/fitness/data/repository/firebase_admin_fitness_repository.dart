import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../messages/data/repository/customer_messages.dart';
import '../../../messages/domain/entities/message_event.dart';
import '../../domain/entities/dynamic_form_field.dart';
import '../../domain/entities/fitness_submission.dart';
import '../../domain/entities/health_program.dart';
import 'fitness_repository.dart';

class FirebaseAdminFitnessRepository implements FitnessRepository {
  static const int pageSize = 100;

  final FirebaseFirestore _db;
  final CustomerMessages _messages;

  FirebaseAdminFitnessRepository(this._db, this._messages);

  CollectionReference<Map<String, dynamic>> get _programs => _db.collection('fitnessPrograms');
  DocumentReference<Map<String, dynamic>> get _config => _db.collection('config').doc('fitness');

  // ===== Programs =====

  /// Sorted here, not with orderBy('order'): Firestore drops documents that
  /// lack the ordered field, which hid every program saved before it existed.
  @override
  Future<List<HealthProgram>> getPrograms() async {
    final snap = await _programs.get();
    final docs = [...snap.docs]
      ..sort((a, b) => ((a.data()['order'] as num?) ?? 1 << 30).compareTo((b.data()['order'] as num?) ?? 1 << 30));
    return docs.map(_programFromDoc).toList();
  }

  @override
  Future<void> saveProgram(HealthProgram program, {required int order}) =>
      _programs.doc(program.id).set({..._programToMap(program), 'order': order});

  @override
  Future<void> deleteProgram(String id) => _programs.doc(id).delete();

  // ===== Submissions =====

  @override
  Future<List<FitnessSubmission>> getSubmissions() async {
    final snap = await _db
        .collectionGroup('submissions')
        .orderBy('submittedAt', descending: true)
        .limit(pageSize)
        .get();
    return snap.docs.map(_submissionFromDoc).toList();
  }

  @override
  Future<void> updateStatus(FitnessSubmission submission, SubmissionStatus status) async {
    final batch = _db.batch()..update(_db.doc(submission.path), {'status': status.key});
    if (status == SubmissionStatus.contacted && submission.status != status) {
      await _addMessage(batch, MessageEvent.fitnessContacted, submission);
    }
    await batch.commit();
  }

  @override
  Future<void> reply(FitnessSubmission submission, String text) async {
    final batch = _db.batch()
      ..update(_db.doc(submission.path), {
        'status': SubmissionStatus.contacted.key,
        'replies': FieldValue.arrayUnion([
          {'text': text, 'at': Timestamp.now()},
        ]),
      });
    // A typed reply always reaches the customer, even with the template off.
    await _addMessage(batch, MessageEvent.fitnessReply, submission, reply: text, force: true);
    await batch.commit();
  }

  Future<void> _addMessage(WriteBatch batch, MessageEvent event, FitnessSubmission s,
      {String? reply, bool force = false}) async {
    if (s.userId == null) return;
    await _messages.templates();
    final message = _messages.compose(event, userId: s.userId!, force: force, values: {
      MessageVar.program: s.programTitle,
      MessageVar.reply: ?reply,
    });
    if (message != null) batch.set(message.ref, message.data);
  }

  // ===== Settings =====

  @override
  Future<String> getSpecialistWhatsapp() async =>
      (await _config.get()).data()?['specialistWhatsapp'] as String? ?? '';

  @override
  Future<void> setSpecialistWhatsapp(String number) =>
      _config.set({'specialistWhatsapp': number.trim()}, SetOptions(merge: true));

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
        'fields': p.fields
            .map((f) => {
                  'id': f.id,
                  'label': f.label,
                  'type': f.type.name,
                  'isRequired': f.isRequired,
                  'options': f.options,
                  'hint': f.hint,
                })
            .toList(),
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
    final raw = d['answers'];
    // New submissions store [{label, value}] in form order; older ones a
    // map keyed by field id.
    final answers = raw is List
        ? [
            for (final a in raw.cast<Map<String, dynamic>>())
              SubmissionAnswer(a['label'] as String? ?? '', '${a['value'] ?? ''}'),
          ]
        : [
            for (final e in (raw as Map? ?? const {}).entries) SubmissionAnswer('${e.key}', '${e.value}'),
          ];
    return FitnessSubmission(
      id: doc.id,
      path: doc.reference.path,
      userId: d['userId'] as String? ?? doc.reference.parent.parent?.id,
      programId: d['programId'] as String? ?? '',
      programTitle: d['programTitle'] as String? ?? d['programId'] as String? ?? '',
      customerName: d['customerName'] as String? ?? '',
      customerPhone: d['customerPhone'] as String? ?? '',
      governorate: d['governorate'] as String?,
      answers: answers,
      status: SubmissionStatus.fromKey(d['status'] as String?),
      submittedAt: (d['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
