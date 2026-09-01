import 'package:equatable/equatable.dart';

class FitnessSubmission extends Equatable {
  final String id;
  final String programId;
  final String programTitle;
  final String submittedByName;
  final String submittedByWhatsapp;
  final Map<String, dynamic> answers;
  final DateTime submittedAt;

  const FitnessSubmission({
    required this.id,
    required this.programId,
    required this.programTitle,
    required this.submittedByName,
    required this.submittedByWhatsapp,
    required this.answers,
    required this.submittedAt,
  });

  @override
  List<Object?> get props => [
    id,
    programId,
    programTitle,
    submittedByName,
    submittedByWhatsapp,
    answers,
    submittedAt,
  ];
}