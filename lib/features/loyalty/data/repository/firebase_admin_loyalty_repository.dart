import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/loyalty_rules.dart';
import '../../domain/entities/loyalty_transaction.dart';
import 'loyalty_repository.dart';

class FirebaseAdminLoyaltyRepository implements LoyaltyRepository {
  final FirebaseFirestore _db;

  FirebaseAdminLoyaltyRepository(this._db);

  @override
  Future<LoyaltyRules> getRules() async {
    final doc = await _db.collection('config').doc('loyaltyRules').get();
    if (!doc.exists) return const LoyaltyRules();
    final d = doc.data()!;
    return LoyaltyRules(
      purchaseRuleEnabled: d['purchaseRuleEnabled'] as bool? ?? true,
      purchaseIsPercentage: d['purchaseIsPercentage'] as bool? ?? false,
      purchaseValue: (d['purchaseValue'] as num? ?? 1).toDouble(),
      appRatingRuleEnabled: d['appRatingRuleEnabled'] as bool? ?? true,
      appRatingPoints: d['appRatingPoints'] as int? ?? 50,
      suggestionRuleEnabled: d['suggestionRuleEnabled'] as bool? ?? true,
      suggestionPoints: d['suggestionPoints'] as int? ?? 30,
      expiryEnabled: d['expiryEnabled'] as bool? ?? false,
      expiryMonths: d['expiryMonths'] as int? ?? 12,
      minRedemption: d['minRedemption'] as int? ?? 100,
    );
  }

  @override
  Future<void> updateRules(LoyaltyRules rules) async {
    await _db.collection('config').doc('loyaltyRules').set({
      'purchaseRuleEnabled': rules.purchaseRuleEnabled,
      'purchaseIsPercentage': rules.purchaseIsPercentage,
      'purchaseValue': rules.purchaseValue,
      'appRatingRuleEnabled': rules.appRatingRuleEnabled,
      'appRatingPoints': rules.appRatingPoints,
      'suggestionRuleEnabled': rules.suggestionRuleEnabled,
      'suggestionPoints': rules.suggestionPoints,
      'expiryEnabled': rules.expiryEnabled,
      'expiryMonths': rules.expiryMonths,
      'minRedemption': rules.minRedemption,
    });
  }

  @override
  Future<List<LoyaltyTransaction>> getTransactions() async {
    final snap = await _db
        .collection('loyaltyTransactions')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return LoyaltyTransaction(
        id: doc.id,
        userName: d['userName'] as String? ?? '',
        userPhone: d['userPhone'] as String? ?? '',
        points: d['points'] as int? ?? 0,
        reason: d['reason'] as String? ?? '',
        reference: d['reference'] as String?,
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> addCorrection({
    required String userName,
    required String userPhone,
    required int points,
    required String reason,
  }) async {
    await _db.collection('loyaltyTransactions').add({
      'userName': userName,
      'userPhone': userPhone,
      'points': points,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}