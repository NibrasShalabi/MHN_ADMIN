import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/deal_promotion.dart';
import 'deals_admin_repository.dart';

/// Firebase implementation لـ DealsAdminRepository
/// نفس الـ promotions collection اللي بيقرأها الـ Client App
class FirebaseAdminDealsRepository implements DealsAdminRepository {
  final FirebaseFirestore _db;

  FirebaseAdminDealsRepository(this._db);

  @override
  Future<List<DealPromotion>> getPromotions() async {
    final snap = await _db
        .collection('promotions')
        .orderBy('startTime', descending: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> addPromotion(DealPromotion promotion) async {
    await _db.collection('promotions').doc(promotion.id).set({
      'productId': promotion.productId,
      'productName': promotion.productName,
      'originalPrice': promotion.originalPrice,
      'discountPercentage': promotion.discountPercentage,
      'startTime': Timestamp.fromDate(promotion.startTime),
      'endTime': Timestamp.fromDate(promotion.endTime),
      'isActive': promotion.isActive,
    });
  }

  @override
  Future<void> cancelPromotion(String id) async {
    await _db.collection('promotions').doc(id).update({
      'isActive': false,
    });
  }

  // ===== Mapper =====

  DealPromotion _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return DealPromotion(
      id: doc.id,
      productId: d['productId'] as String? ?? '',
      productName: d['productName'] as String? ?? '',
      originalPrice: (d['originalPrice'] as num? ?? 0).toDouble(),
      discountPercentage: (d['discountPercentage'] as num? ?? 0).toDouble(),
      startTime: (d['startTime'] as Timestamp).toDate(),
      endTime: (d['endTime'] as Timestamp).toDate(),
      isActive: d['isActive'] as bool? ?? true,
    );
  }
}