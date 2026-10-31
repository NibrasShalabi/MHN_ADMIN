import '../../domain/entities/analytics_data.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsData> getAnalytics();

  /// One read of config/stats — the dashboard's user count without the full analytics load.
  Future<int> totalUsers();
}