import 'package:equatable/equatable.dart';

import '../../domain/entities/analytics_data.dart';

enum AnalyticsPageStatus { initial, loading, loaded, error }

enum AnalyticsPeriod { today, sevenDays, thirtyDays }

class AnalyticsState extends Equatable {
  final AnalyticsPageStatus status;
  final AnalyticsData data;
  final AnalyticsPeriod period;
  final String? errorMessage;

  const AnalyticsState({
    this.status = AnalyticsPageStatus.initial,
    this.data = const AnalyticsData(),
    this.period = AnalyticsPeriod.sevenDays,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    AnalyticsPageStatus? status,
    AnalyticsData? data,
    AnalyticsPeriod? period,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      data: data ?? this.data,
      period: period ?? this.period,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, period, errorMessage];
}