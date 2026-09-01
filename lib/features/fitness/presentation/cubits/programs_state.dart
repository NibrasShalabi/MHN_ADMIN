import 'package:equatable/equatable.dart';

import '../../domain/entities/health_program.dart';

enum ProgramsStatus { initial, loading, loaded, error }

class ProgramsState extends Equatable {
  final ProgramsStatus status;
  final List<HealthProgram> programs;
  final String? errorMessage;

  const ProgramsState({
    this.status = ProgramsStatus.initial,
    this.programs = const [],
    this.errorMessage,
  });

  ProgramsState copyWith({
    ProgramsStatus? status,
    List<HealthProgram>? programs,
    String? errorMessage,
  }) {
    return ProgramsState(
      status: status ?? this.status,
      programs: programs ?? this.programs,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, programs, errorMessage];
}