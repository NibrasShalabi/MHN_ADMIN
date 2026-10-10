import 'package:equatable/equatable.dart';

import '../../domain/entities/deal_promotion.dart';

enum DealsAdminStatus { initial, loading, success, failure }

class DealsAdminState extends Equatable {
  final DealsAdminStatus status;
  final List<DealPromotion> promotions;

  /// Active deals whose product no longer exists — the app can't show them.
  final Set<String> missingProductIds;
  final String? error;

  /// Bumped every minute so the countdowns redraw.
  final int tick;

  const DealsAdminState({
    this.status = DealsAdminStatus.initial,
    this.promotions = const [],
    this.missingProductIds = const {},
    this.error,
    this.tick = 0,
  });

  List<DealPromotion> get active => promotions.where((p) => p.isActive && !p.isExpired).toList();

  List<DealPromotion> get expired => promotions.where((p) => !p.isActive || p.isExpired).toList();

  bool hasActivePromotion(String productId) => active.any((p) => p.productId == productId);

  bool isMissing(DealPromotion p) => missingProductIds.contains(p.productId);

  DealsAdminState copyWith({
    DealsAdminStatus? status,
    List<DealPromotion>? promotions,
    Set<String>? missingProductIds,
    String? error,
    int? tick,
  }) =>
      DealsAdminState(
        status: status ?? this.status,
        promotions: promotions ?? this.promotions,
        missingProductIds: missingProductIds ?? this.missingProductIds,
        error: error,
        tick: tick ?? this.tick,
      );

  @override
  List<Object?> get props => [status, promotions, missingProductIds, error, tick];
}
