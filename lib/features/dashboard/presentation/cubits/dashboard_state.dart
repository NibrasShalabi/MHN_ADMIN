import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_summary.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardSummary summary;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.summary = const DashboardSummary(),
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSummary? summary,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}