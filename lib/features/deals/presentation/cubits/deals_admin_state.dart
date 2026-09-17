import 'package:equatable/equatable.dart';
import '../../domain/entities/deal_promotion.dart';

enum DealsAdminStatus { initial, loading, success, failure }

class DealsAdminState extends Equatable {
  final DealsAdminStatus status;
  final List<DealPromotion> promotions;
  final String? error;

  const DealsAdminState({
    this.status = DealsAdminStatus.initial,
    this.promotions = const [],
    this.error,
  });

  List<DealPromotion> get active =>
      promotions.where((p) => p.isActive && !p.isExpired).toList();

  List<DealPromotion> get expired =>
      promotions.where((p) => !p.isActive || p.isExpired).toList();

  // ثغرة 3: تحقق سريع من وجود عرض نشط لمنتج معين
  bool hasActivePromotion(String productId) =>
      active.any((p) => p.productId == productId);

  DealsAdminState copyWith({
    DealsAdminStatus? status,
    List<DealPromotion>? promotions,
    String? error,
  }) =>
      DealsAdminState(
        status: status ?? this.status,
        promotions: promotions ?? this.promotions,
        error: error,
      );

  @override
  List<Object?> get props => [status, promotions, error];
}