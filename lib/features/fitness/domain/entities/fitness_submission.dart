import 'package:equatable/equatable.dart';

enum SubmissionStatus {
  pending('new', 'جديد'),
  contacted('contacted', 'تم التواصل'),
  closed('closed', 'مغلق');

  final String key;
  final String label;
  const SubmissionStatus(this.key, this.label);

  static SubmissionStatus fromKey(String? key) =>
      values.firstWhere((s) => s.key == key, orElse: () => pending);
}

/// One question and the customer's answer, with the question text as it
/// was when she answered — editing the form later can't relabel old data.
class SubmissionAnswer extends Equatable {
  final String label;
  final String value;

  const SubmissionAnswer(this.label, this.value);

  @override
  List<Object?> get props => [label, value];
}

class FitnessSubmission extends Equatable {
  final String id;

  /// Full document path — submissions live under each customer
  /// (fitnessProfiles/{uid}/submissions/{id}).
  final String path;
  final String? userId;
  final String programId;
  final String programTitle;
  final String customerName;
  final String customerPhone;
  final String? governorate;
  final List<SubmissionAnswer> answers;
  final SubmissionStatus status;
  final DateTime submittedAt;

  const FitnessSubmission({
    required this.id,
    required this.path,
    this.userId,
    required this.programId,
    required this.programTitle,
    required this.customerName,
    required this.customerPhone,
    this.governorate,
    required this.answers,
    this.status = SubmissionStatus.pending,
    required this.submittedAt,
  });

  FitnessSubmission withStatus(SubmissionStatus s) => FitnessSubmission(
        id: id,
        path: path,
        userId: userId,
        programId: programId,
        programTitle: programTitle,
        customerName: customerName,
        customerPhone: customerPhone,
        governorate: governorate,
        answers: answers,
        status: s,
        submittedAt: submittedAt,
      );

  /// wa.me wants digits with the country code: 0912… → 963912…
  String? get whatsappUrl {
    var digits = customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = '963${digits.substring(1)}';
    return 'https://wa.me/$digits';
  }

  @override
  List<Object?> get props =>
      [id, path, userId, programId, programTitle, customerName, customerPhone, governorate, answers, status, submittedAt];
}
