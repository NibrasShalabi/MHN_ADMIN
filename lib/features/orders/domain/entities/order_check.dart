import 'package:equatable/equatable.dart';

/// Totals re-computed from today's products, promotions and shipping table,
/// compared with what the order says the customer owes.
class OrderCheck extends Equatable {
  final double expectedItems;
  final double expectedSupplyShipping;
  final double expectedDelivery;

  const OrderCheck({required this.expectedItems, required this.expectedSupplyShipping, required this.expectedDelivery});

  double get expectedTotal => expectedItems + expectedSupplyShipping + expectedDelivery;

  /// Rounding differences of under 1 are ignored.
  bool matches(double total) => (expectedTotal - total).abs() < 1;

  @override
  List<Object?> get props => [expectedItems, expectedSupplyShipping, expectedDelivery];
}
