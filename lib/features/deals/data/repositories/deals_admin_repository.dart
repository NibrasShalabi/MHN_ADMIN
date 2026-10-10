import '../../domain/entities/deal_promotion.dart';

abstract class DealsAdminRepository {
  Future<List<DealPromotion>> getPromotions();
  Future<void> addPromotion(DealPromotion promotion);
  Future<void> cancelPromotion(String id);

  /// Which of [productIds] have no product document.
  Future<Set<String>> missingProducts(Iterable<String> productIds);
}
