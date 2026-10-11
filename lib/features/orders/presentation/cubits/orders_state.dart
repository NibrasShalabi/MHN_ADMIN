import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_batch.dart';

enum OrdersStatus { initial, loading, loaded, error }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<Order> orders;
  final List<OrderBatch> batches;
  final String? errorMessage;

  /// The last page was full, so older entries may exist.
  final bool hasMore;
  final bool loadingMore;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.batches = const [],
    this.errorMessage,
    this.hasMore = false,
    this.loadingMore = false,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<Order>? orders,
    List<OrderBatch>? batches,
    String? errorMessage,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      batches: batches ?? this.batches,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  @override
  List<Object?> get props => [status, orders, batches, errorMessage, hasMore, loadingMore];
}