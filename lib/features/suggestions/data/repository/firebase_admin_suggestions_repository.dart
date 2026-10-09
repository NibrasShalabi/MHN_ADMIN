import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product_suggestion.dart';
import 'suggestions_repository.dart';

class FirebaseAdminSuggestionsRepository implements SuggestionsRepository {
  static const int _whereInLimit = 30;

  final FirebaseFirestore _db;

  FirebaseAdminSuggestionsRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _suggestions => _db.collection('productSuggestions');

  @override
  Future<List<ProductSuggestion>> getSuggestions() async {
    final snap = await _suggestions.orderBy('submittedAt', descending: true).get();

    // Newer suggestions carry the name; older ones are looked up 30 users per read.
    final missing = {
      for (final d in snap.docs)
        if (d.data()['userName'] == null) d.data()['userId'] as String?,
    }.whereType<String>().where((id) => id.isNotEmpty).toList();
    final names = <String, String>{};
    for (var i = 0; i < missing.length; i += _whereInLimit) {
      final chunk = missing.sublist(i, (i + _whereInLimit).clamp(0, missing.length));
      final users = await _db.collection('users').where(FieldPath.documentId, whereIn: chunk).get();
      for (final u in users.docs) {
        final name = '${u.data()['fullName'] ?? ''} ${u.data()['familyName'] ?? ''}'.trim();
        if (name.isNotEmpty) names[u.id] = name;
      }
    }

    return [
      for (final doc in snap.docs)
        ProductSuggestion(
          id: doc.id,
          suggestedBy: doc.data()['userName'] as String? ??
              names[doc.data()['userId']] ??
              doc.data()['userId'] as String? ??
              '',
          productName: doc.data()['productName'] as String? ?? '',
          link: doc.data()['productLink'] as String? ?? '',
          status: _mapStatus(doc.data()['status'] as String?),
          createdAt: (doc.data()['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ),
    ];
  }

  /// Approval rewards the customer once, per config/loyaltyRules, and tells them.
  @override
  Future<void> approve(String id) async {
    final ref = _suggestions.doc(id);
    await _db.runTransaction((tx) async {
      final s = (await tx.get(ref)).data() ?? const <String, dynamic>{};
      final rules = (await tx.get(_db.collection('config').doc('loyaltyRules'))).data() ?? const {};
      final userId = s['userId'] as String?;
      final alreadyRewarded = s['pointsAwarded'] != null;
      final reward = rules['suggestionRuleEnabled'] == false ? 0 : (rules['suggestionPoints'] as num? ?? 0).toInt();
      final rewarding = userId != null && !alreadyRewarded && reward > 0;

      tx.update(ref, {'status': 'approved', if (rewarding) 'pointsAwarded': reward});

      if (rewarding) {
        tx.update(_db.collection('users').doc(userId), {'loyaltyPoints': FieldValue.increment(reward)});
        tx.set(_db.collection('loyaltyTransactions').doc('suggestion_$id'), {
          'userId': userId,
          'points': reward,
          'reason': 'اقتراح منتج مقبول',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      if (userId != null && s['status'] != 'approved') {
        final name = s['productName'] as String? ?? '';
        tx.set(_db.collection('admin_messages').doc(), {
          'type': 'suggestion',
          'userId': userId,
          'title': 'تم قبول اقتراحك',
          'body': rewarding ? 'شكراً لاقتراح "$name" — انضافلك $reward نقطة.' : 'شكراً لاقتراح "$name".',
          'isRead': false,
          'sentAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<void> reject(String id, String reason) async {
    final doc = await _suggestions.doc(id).get();
    final userId = doc.data()?['userId'] as String?;
    final productName = doc.data()?['productName'] as String? ?? '';

    final batch = _db.batch()..update(_suggestions.doc(id), {'status': 'rejected', 'rejectionReason': reason});
    if (userId != null) {
      batch.set(_db.collection('admin_messages').doc(), {
        'type': 'suggestion',
        'userId': userId,
        'title': 'تم رفض اقتراحك',
        'body': 'اقتراح "$productName" ما انقبل. السبب: $reason',
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
    await batch.commit();
  }

  SuggestionStatus _mapStatus(String? value) => switch (value) {
        'approved' => SuggestionStatus.approved,
        'rejected' => SuggestionStatus.rejected,
        _ => SuggestionStatus.underReview,
      };
}
