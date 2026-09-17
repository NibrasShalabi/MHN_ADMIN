import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/deals_admin_repository.dart';
import '../../domain/entities/deal_promotion.dart';
import 'deals_admin_state.dart';

class DealsAdminCubit extends Cubit<DealsAdminState> {
  final DealsAdminRepository _repository;
  Timer? _refreshTimer;

  DealsAdminCubit(this._repository) : super(const DealsAdminState());

  Future<void> load() async {
    emit(state.copyWith(status: DealsAdminStatus.loading));
    try {
      final promotions = await _repository.getPromotions();

      // ثغرة 1: فلتر المنتجات المحذوفة — لما Firebase يجي بنتحقق من وجود المنتج
      // بالـ Fake phase: نعتمد على isActive فقط
      emit(state.copyWith(status: DealsAdminStatus.success, promotions: promotions));

      _startRefreshTimer();
    } catch (e) {
      emit(state.copyWith(status: DealsAdminStatus.failure, error: e.toString()));
    }
  }

  // ثغرة 2: refresh تلقائي كل دقيقة لتحديث الـ countdown
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (state.status == DealsAdminStatus.success) {
        // نحدث الـ state بدون loading لتجنب الـ flicker
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

  // ثغرة 3: تحقق من وجود عرض نشط قبل الإضافة
  Future<DealsAdminResult> addPromotion({
    required String productId,
    required String productName,
    required double originalPrice,
    required double discountPercentage,
    required int durationHours,
  }) async {
    // تحقق من عرض نشط على نفس المنتج
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