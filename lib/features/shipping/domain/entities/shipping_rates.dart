import 'package:equatable/equatable.dart';

/// Delivery from the shop to the customer, per governorate — `config/shipping`.
///
/// The client app computes the same fee at checkout; keep [deliveryFor] in
/// step with the client's copy.
class ShippingRates extends Equatable {
  final Map<String, double> fees;

  /// Free delivery above [freeAbove] — kept off until it's agreed with the client.
  final bool freeEnabled;
  final double freeAbove;

  const ShippingRates({this.fees = const {}, this.freeEnabled = false, this.freeAbove = 0});

  double deliveryFor(String? governorate, double itemsTotal) {
    if (freeEnabled && freeAbove > 0 && itemsTotal >= freeAbove) return 0;
    return fees[governorate] ?? 0;
  }

  factory ShippingRates.fromMap(Map<String, dynamic> d) => ShippingRates(
        fees: {
          for (final e in (d['fees'] as Map? ?? const {}).entries) e.key as String: (e.value as num).toDouble(),
        },
        freeEnabled: d['freeEnabled'] as bool? ?? false,
        freeAbove: (d['freeAbove'] as num? ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {'fees': fees, 'freeEnabled': freeEnabled, 'freeAbove': freeAbove};

  ShippingRates copyWith({Map<String, double>? fees, bool? freeEnabled, double? freeAbove}) => ShippingRates(
        fees: fees ?? this.fees,
        freeEnabled: freeEnabled ?? this.freeEnabled,
        freeAbove: freeAbove ?? this.freeAbove,
      );

  @override
  List<Object?> get props => [fees, freeEnabled, freeAbove];
}
