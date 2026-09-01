import '../../domain/entities/analytics_data.dart';
import 'analytics_repository.dart';

class FakeAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<AnalyticsData> getAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    final daily = List.generate(30, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      final orders = 5 + (i % 7);
      return DailyPoint(
        date: date,
        orders: orders,
        completed: orders - (i % 3),
        cancelled: i % 3,
        revenue: (orders * 25000).toDouble(),
        newUsers: 1 + (i % 4),
      );
    });

    return AnalyticsData(
      daily: daily,
      topCategories: const [
        RankedEntry(name: 'العناية بالبشرة', value: 420),
        RankedEntry(name: 'برامج اللياقة', value: 210),
        RankedEntry(name: 'العناية بالشعر', value: 150),
      ],
      topProducts: const [
        RankedEntry(name: 'سيروم 1', value: 88),
        RankedEntry(name: 'سيروم 4', value: 61),
        RankedEntry(name: 'سيروم 2', value: 47),
      ],
      totalUsers: 356,
    );
  }
}