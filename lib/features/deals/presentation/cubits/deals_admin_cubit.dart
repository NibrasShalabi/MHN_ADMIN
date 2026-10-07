import 'dart:async';
import '../../../../core/bloc/safe_cubit.dart';
import '../../data/repositories/deals_admin_repository.dart';
import '../../domain/entities/deal_promotion.dart';
import 'deals_admin_state.dart';

class DealsAdminCubit extends SafeCubit<DealsAdminState> {
  final DealsAdminRepository _repository;
  Timer? _refreshTimer;

  DealsAdminCubit(this._repository) : super(const DealsAdminState());

  Future<void> load() async {
    emit(state.copyWith(status: DealsAdminStatus.loading));
    try {
      final promotions = await _repository.getPromotions();

      // ط«ط؛ط±ط© 1: ظپظ„طھط± ط§ظ„ظ…ظ†طھط¬ط§طھ ط§ظ„ظ…ط­ط°ظˆظپط© â€” ظ„ظ…ط§ Firebase ظٹط¬ظٹ ط¨ظ†طھط­ظ‚ظ‚ ظ…ظ† ظˆط¬ظˆط¯ ط§ظ„ظ…ظ†طھط¬
      // ط¨ط§ظ„ظ€ Fake phase: ظ†ط¹طھظ…ط¯ ط¹ظ„ظ‰ isActive ظپظ‚ط·
      emit(state.copyWith(status: DealsAdminStatus.success, promotions: promotions));

      _startRefreshTimer();
    } catch (e) {
      emit(state.copyWith(status: DealsAdminStatus.failure, error: e.toString()));
    }
  }

  // ط«ط؛ط±ط© 2: refresh طھظ„ظ‚ط§ط¦ظٹ ظƒظ„ ط¯ظ‚ظٹظ‚ط© ظ„طھط­ط¯ظٹط« ط§ظ„ظ€ countdown
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (state.status == DealsAdminStatus.success) {
        // ظ†ط­ط¯ط« ط§ظ„ظ€ state ط¨ط¯ظˆظ† loading ظ„طھط¬ظ†ط¨ ط§ظ„ظ€ flicker
        _refreshPromotions();
      }
    });
  }

  Future<void> _refreshPromotions() async {
    try {
      final promotions = await _repository.getPromotions();
      emit(state.copyWith(promotions: promotions));
    } catch (_) {}
  }

  // ط«ط؛ط±ط© 3: طھط­ظ‚ظ‚ ظ…ظ† ظˆط¬ظˆط¯ ط¹ط±ط¶ ظ†ط´ط· ظ‚ط¨ظ„ ط§ظ„ط¥ط¶ط§ظپط©
  Future<DealsAdminResult> addPromotion({
    required String productId,
    required String productName,
    required double originalPrice,
    required double discountPercentage,
    required int durationHours,
  }) async {
    // طھط­ظ‚ظ‚ ظ…ظ† ط¹ط±ط¶ ظ†ط´ط· ط¹ظ„ظ‰ ظ†ظپط³ ط§ظ„ظ…ظ†طھط¬
    final hasActive = state.active.any((p) => p.productId == productId);
    if (hasActive) return DealsAdminResult.duplicatePromotion;

    final promo = DealPromotion(
      id: 'promo_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      productName: productName,
      originalPrice: originalPrice,
      discountPercentage: discountPercentage,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: durationHours)),
    );

    await _repository.addPromotion(promo);
    await _refreshPromotions();
    return DealsAdminResult.success;
  }

  Future<void> cancelPromotion(String id) async {
    await _repository.cancelPromotion(id);
    await _refreshPromotions();
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}

enum DealsAdminResult { success, duplicatePromotion }