import '../../domain/entities/deal_promotion.dart';

abstract class DealsAdminRepository {
  Future<List<DealPromotion>> getPromotions();
  Future<void> addPromotion(DealPromotion promotion);
  Future<void> cancelPromotion(String id);
}

class FakeDealsAdminRepository implements DealsAdminRepository {
  final List<DealPromotion> _promotions = [
    DealPromotion(
      id: 'promo_1',
      productId: 'P-1',
      productName: 'سيروم 1',
      originalPrice: 16250,
      discountPercentage: 70,
      startTime: DateTime.now().subtract(const Duration(hours: 5)),
      endTime: DateTime.now().add(const Duration(hours: 19)),
    ),
    DealPromotion(
      id: 'promo_2',
      productId: 'P-2',
      productName: 'سيروم 2',
      originalPrice: 17500,
      discountPercentage: 50,
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 22)),
    ),
    DealPromotion(
      id: 'promo_3',
      productId: 'P-3',
      productName: 'سيروم 3',
      originalPrice: 18750,
      discountPercentage: 40,
      startTime: DateTime.now().subtract(const Duration(days: 1)),
      endTime: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: false,
    ),
  ];

  @override
  Future<List<DealPromotion>> getPromotions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_promotions);
  }

  @override
  Future<void> addPromotion(DealPromotion promotion) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _promotions.add(promotion);
  }

  @override
  Future<void> cancelPromotion(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final i = _promotions.indexWhere((p) => p.id == id);
    if (i != -1) _promotions[i] = _promotions[i].copyWith(isActive: false);
  }
}