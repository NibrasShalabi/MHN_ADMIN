import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/loyalty_rules.dart';
import '../../domain/entities/loyalty_transaction.dart';
import 'loyalty_repository.dart';
import '../../../../core/data/admin_cache.dart';
import '../../domain/entities/loyalty_leader.dart';

class FirebaseAdminLoyaltyRepository implements LoyaltyRepository {
  final FirebaseFirestore _db;

  FirebaseAdminLoyaltyRepository(this._db);

  @override
  Future<LoyaltyRules> getRules() => AdminCache.get('FirebaseAdminLoyaltyRepository.getRules', () async {
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
  });

  @override
  Future<void> updateRules(LoyaltyRules rules) async {
    AdminCache.clear();
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
  Future<List<LoyaltyTransaction>> getTransactions({DateTime? before}) {
    final q = _db.collection('loyaltyTransactions').orderBy('createdAt', descending: true).limit(pageSize);
    if (before != null) return _loadTransactions(q.startAfter([Timestamp.fromDate(before)]));
    return AdminCache.get('loyalty.first', () => _loadTransactions(q));
  }

  static const int pageSize = 100;

  /// 50 reads at most — the real balances, not sums of a partial ledger.
  @override
  Future<List<LoyaltyLeader>> topBalances() => AdminCache.get('loyalty.top', () async {
        final snap = await _db
            .collection('users')
            .where('loyaltyPoints', isGreaterThan: 0)
            .orderBy('loyaltyPoints', descending: true)
            .limit(50)
            .get();
        return [
          for (final d in snap.docs)
            LoyaltyLeader(
              name: '${d.data()['fullName'] ?? ''} ${d.data()['familyName'] ?? ''}'.trim(),
              phone: d.data()['phone'] as String? ?? '',
              points: (d.data()['loyaltyPoints'] as num?)?.toInt() ?? 0,
            ),
        ];
      });

  Future<List<LoyaltyTransaction>> _loadTransactions(Query<Map<String, dynamic>> query) async {
    final snap = await query.get();
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
    AdminCache.clear();
    await _db.collection('loyaltyTransactions').add({
      'userName': userName,
      'userPhone': userPhone,
      'points': points,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}