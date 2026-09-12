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
  final num value;

  const RankedEntry({required this.name, required this.value});

  @override
  List<Object?> get props => [name, value];
}

class AnalyticsData extends Equatable {
  final List<DailyPoint> daily;
  final List<RankedEntry> topCategories;
  final List<RankedEntry> topProducts;
  final List<RankedEntry> topLoyaltyEarners;
  final int totalUsers;

  // Financial (8.3) — netProfit is an estimate: orders don't currently
  // record which product line each item was, so it's revenue times the
  // average margin across priced products rather than a true per-order
  // cost sum. Exact once orders link items to a product id.
  final double netProfit;
  final double averageOrderValue;

  // Customers (8.3)
  final List<RankedEntry> topOrderingCustomers;
  final List<RankedEntry> topSpendingCustomers;
  final List<RankedEntry> topComplainingCustomers;
  final List<RankedEntry> mostActiveCustomers;

  // Suppliers (8.3) — placeholder: there's no supplier CRUD yet to
  // attribute real sales to, so this stays empty until that exists
  // rather than showing invented numbers.
  final List<RankedEntry> topSellingSuppliers;

  // Fitness (8.3) — only the part that's honestly measurable from data
  // that exists. "Form completion rate" and "most-viewed supplements"
  // would need client-side view/drop-off tracking, which nothing in
  // this app currently records — showing a number for those would be
  // decoration, not a stat.
  final List<RankedEntry> topPrograms;

  const AnalyticsData({
    this.daily = const [],
    this.topCategories = const [],
    this.topProducts = const [],
    this.topLoyaltyEarners = const [],
    this.totalUsers = 0,
    this.netProfit = 0,
    this.averageOrderValue = 0,
    this.topOrderingCustomers = const [],
    this.topSpendingCustomers = const [],
    this.topComplainingCustomers = const [],
    this.mostActiveCustomers = const [],
    this.topSellingSuppliers = const [],
    this.topPrograms = const [],
  });

  @override
  List<Object?> get props => [
    daily,
    topCategories,
    topProducts,
    topLoyaltyEarners,
    totalUsers,
    netProfit,
    averageOrderValue,
    topOrderingCustomers,
    topSpendingCustomers,
    topComplainingCustomers,
    mostActiveCustomers,
    topSellingSuppliers,
    topPrograms,
  ];
}