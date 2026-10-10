import 'dart:async';

import '../../../../core/bloc/safe_cubit.dart';
import '../../data/repositories/deals_admin_repository.dart';
import '../../domain/entities/deal_promotion.dart';
import 'deals_admin_state.dart';

enum DealsAdminResult { success, duplicatePromotion, invalid, failure }

class DealsAdminCubit extends SafeCubit<DealsAdminState> {
  final DealsAdminRepository _repository;
  Timer? _ticker;

  DealsAdminCubit(this._repository) : super(const DealsAdminState());

  Future<void> load() async {
    emit(state.copyWith(status: DealsAdminStatus.loading));
    try {
      await _refresh();
      emit(state.copyWith(status: DealsAdminStatus.success));
      // Countdown only — re-emits the same data, never re-reads Firestore.
      _ticker ??= Timer.periodic(const Duration(minutes: 1), (_) => emit(state.copyWith(tick: state.tick + 1)));
    } catch (e) {
      emit(state.copyWith(status: DealsAdminStatus.failure, error: e.toString()));
    }
  }

  Future<void> _refresh() async {
    final promotions = await _repository.getPromotions();
    final activeIds = promotions.where((p) => p.isActive && !p.isExpired).map((p) => p.productId);
    final missing = await _repository.missingProducts(activeIds);
    emit(state.copyWith(promotions: promotions, missingProductIds: missing));
  }

  Future<DealsAdminResult> addPromotion({
    required String productId,
    required String productName,
    required double originalPrice,
    required double discountPercentage,
    required int durationHours,
  }) async {
    if (discountPercentage <= 0 || discountPercentage >= 100 || durationHours <= 0) return DealsAdminResult.invalid;
    if (state.hasActivePromotion(productId)) return DealsAdminResult.duplicatePromotion;

    final now = DateTime.now();
    try {
      await _repository.addPromotion(DealPromotion(
        id: 'promo_${now.millisecondsSinceEpoch}',
        productId: productId,
        productName: productName,
        originalPrice: originalPrice,
        discountPercentage: discountPercentage,
        startTime: now,
        endTime: now.add(Duration(hours: durationHours)),
      ));
      await _refresh();
      return DealsAdminResult.success;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return DealsAdminResult.failure;
    }
  }

  Future<void> cancelPromotion(String id) async {
    try {
      await _repository.cancelPromotion(id);
      await _refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
