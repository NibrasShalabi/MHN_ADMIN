import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/analytics_repository.dart';
import '../../domain/entities/analytics_data.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsCubit(this._repository) : super(const AnalyticsState());

  Future<void> load() async {
    emit(state.copyWith(status: AnalyticsPageStatus.loading));
    try {
      final data = await _repository.getAnalytics();
      emit(state.copyWith(status: AnalyticsPageStatus.loaded, data: data));
    } catch (e) {
      emit(state.copyWith(status: AnalyticsPageStatus.error, errorMessage: e.toString()));
    }
  }

  void setPeriod(AnalyticsPeriod period) {
    emit(state.copyWith(period: period));
  }

  List<DailyPoint> get filteredDaily {
    final days = switch (state.period) {
      AnalyticsPeriod.today => 1,
      AnalyticsPeriod.sevenDays => 7,
      AnalyticsPeriod.thirtyDays => 30,
    };
    final all = state.data.daily;
    return all.length <= days ? all : all.sublist(all.length - days);
  }

  /// The window immediately before [filteredDaily], same length — the
  /// baseline the up/down arrows on the stat cards compare against.
  /// Empty when there isn't enough history yet (e.g. the 30-day period
  /// against a 30-day fake dataset), and the UI hides the arrow then
  /// rather than showing a comparison against nothing.
  List<DailyPoint> get previousDaily {
    final days = switch (state.period) {
      AnalyticsPeriod.today => 1,
      AnalyticsPeriod.sevenDays => 7,
      AnalyticsPeriod.thirtyDays => 30,
    };
    final all = state.data.daily;
    final currentStart = all.length - days;
    final previousStart = currentStart - days;
    if (currentStart <= 0 || previousStart < 0) return const [];
    return all.sublist(previousStart, currentStart);
  }
}