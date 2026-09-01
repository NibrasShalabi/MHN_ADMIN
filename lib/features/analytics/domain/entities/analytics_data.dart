import 'package:equatable/equatable.dart';

class DailyPoint extends Equatable {
  final DateTime date;
  final int orders;
  final int completed;
  final int cancelled;
  final double revenue;
  final int newUsers;

  const DailyPoint({
    required this.date,
    required this.orders,
    required this.completed,
    required this.cancelled,
    required this.revenue,
    required this.newUsers,
  });

  @override
  List<Object?> get props => [date, orders, completed, cancelled, revenue, newUsers];
}

class RankedEntry extends Equatable {
  final String name;
  final int value;

  const RankedEntry({required this.name, required this.value});

  @override
  List<Object?> get props => [name, value];
}

class AnalyticsData extends Equatable {
  final List<DailyPoint> daily;
  final List<RankedEntry> topCategories;
  final List<RankedEntry> topProducts;
  final int totalUsers;

  const AnalyticsData({
    this.daily = const [],
    this.topCategories = const [],
    this.topProducts = const [],
    this.totalUsers = 0,
  });

  @override
  List<Object?> get props => [daily, topCategories, topProducts, totalUsers];
}