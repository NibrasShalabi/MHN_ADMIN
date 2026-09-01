import 'package:equatable/equatable.dart';

import '../../domain/entities/fitness_submission.dart';

enum SubmissionsStatus { initial, loading, loaded, error }

class SubmissionsState extends Equatable {
  final SubmissionsStatus status;
  final List<FitnessSubmission> submissions;
  final String? errorMessage;

  const SubmissionsState({
    this.status = SubmissionsStatus.initial,
    this.submissions = const [],
    this.errorMessage,
  });

  SubmissionsState copyWith({
    SubmissionsStatus? status,
    List<FitnessSubmission>? submissions,
    String? errorMessage,
  }) {
    return SubmissionsState(
      status: status ?? this.status,
      submissions: submissions ?? this.submissions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, submissions, errorMessage];
}