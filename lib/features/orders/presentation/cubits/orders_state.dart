import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';

enum OrdersStatus { initial, loading, loaded, error }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<Order> orders;
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<Order>? orders,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage];
}