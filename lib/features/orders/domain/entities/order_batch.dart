import 'package:equatable/equatable.dart';

/// A named group of orders — e.g. "شحنة 15 آذار" — so the admin can move
/// several orders through a status change and notify their customers in
/// one action instead of order by order.
///
/// Deliberately thin: it doesn't duplicate order data, just references
/// [orderIds]. The bulk status/message action reuses the existing
/// per-order [OrdersRepository.updateOrderStatus] call for each id, so a
/// batch is a grouping on top of that flow, not a parallel one.
class OrderBatch extends Equatable {
  final String id;
  final String name;
  final List<String> orderIds;
  final DateTime createdAt;

  const OrderBatch({
    required this.id,
    required this.name,
    required this.orderIds,
    required this.createdAt,
  });

  OrderBatch copyWith({String? name, List<String>? orderIds}) {
    return OrderBatch(
      id: id,
      name: name ?? this.name,
      orderIds: orderIds ?? this.orderIds,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, orderIds, createdAt];
}