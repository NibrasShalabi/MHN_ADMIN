import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order.dart';

class DashboardSummary extends Equatable {
  final int pendingOrders;
  final int unreviewedSuggestions;
  final int openSupportMessages;
  final int outOfStockProducts;
  final int fitnessSubmissions;
  final int todayOrders;
  final double todayRevenue;
  final int completedOrdersToday;
  final int approxUsers;
  final List<Order> recentOrders;

  const DashboardSummary({
    this.pendingOrders = 0,
    this.unreviewedSuggestions = 0,
    this.openSupportMessages = 0,
    this.outOfStockProducts = 0,
    this.fitnessSubmissions = 0,
    this.todayOrders = 0,
    this.todayRevenue = 0,
    this.completedOrdersToday = 0,
    this.approxUsers = 0,
    this.recentOrders = const [],
  });

  @override
  List<Object?> get props => [
    pendingOrders,
    unreviewedSuggestions,
    openSupportMessages,
    outOfStockProducts,
    fitnessSubmissions,
    todayOrders,
    todayRevenue,
    completedOrdersToday,
    approxUsers,
    recentOrders,
  ];
}