import '../../../../core/constants/admin_strings.dart';
import '../cubits/analytics_state.dart';

extension AnalyticsPeriodX on AnalyticsPeriod {
  String get label => switch (this) {
    AnalyticsPeriod.today => AdminStrings.periodToday,
    AnalyticsPeriod.sevenDays => AdminStrings.period7Days,
    AnalyticsPeriod.thirtyDays => AdminStrings.period30Days,
  };
}