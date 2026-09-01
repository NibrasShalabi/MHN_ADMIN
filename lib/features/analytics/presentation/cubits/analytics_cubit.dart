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
}