import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product_suggestion.dart';
import 'suggestions_repository.dart';

class FirebaseAdminSuggestionsRepository implements SuggestionsRepository {
  final FirebaseFirestore _db;

  FirebaseAdminSuggestionsRepository(this._db);

  @override
  @override
  Future<List<ProductSuggestion>> getSuggestions() async {
    final snap = await _db
        .collection('productSuggestions')
        .orderBy('submittedAt', descending: true)
        .get();

    // جيب أسماء المستخدمين بـ parallel
    final suggestions = await Future.wait(snap.docs.map((doc) async {
      final d = doc.data();
      final userId = d['userId'] as String? ?? '';

      String userName = userId;
      try {
        final userDoc = await _db.collection('users').doc(userId).get();
        final fullName = userDoc.data()?['fullName'] as String?;
        final familyName = userDoc.data()?['familyName'] as String?;
        if (fullName != null) {
          userName = '$fullName ${familyName ?? ''}'.trim();
        }
      } catch (_) {}

      return ProductSuggestion(
        id: doc.id,
        suggestedBy: userName,
        productName: d['productName'] as String? ?? '',
        link: d['productLink'] as String? ?? '',
        status: _mapStatus(d['status'] as String?),
        createdAt: (d['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }));

    return suggestions;
  }
  @override
  Future<void> approve(String id) async {
    await _db.collection('productSuggestions').doc(id).update({
      'status': 'approved',
    });
  }

  @override
  @override
  Future<void> reject(String id, String reason) async {
    final doc = await _db.collection('productSuggestions').doc(id).get();
    final userId = doc.data()?['userId'] as String?;
    final productName = doc.data()?['productName'] as String? ?? '';

    final batch = _db.batch();

    // تحديث الـ suggestion
    batch.update(
      _db.collection('productSuggestions').doc(id),
      {'status': 'rejected', 'rejectionReason': reason},
    );

    // إرسال رسالة للمستخدم
    if (userId != null) {
      batch.set(
        _db.collection('admin_messages').doc(),
        {
          'userId': userId,
          'body': 'تم رفض اقتراحك لمنتج "$productName". السبب: $reason',
          'sentAt': FieldValue.serverTimestamp(),
          'isRead': false,
        },
      );
    }

    await batch.commit();
  }

  ProductSuggestion _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ProductSuggestion(
      id: doc.id,
      suggestedBy: d['userId'] as String? ?? '',
      productName: d['productName'] as String? ?? '',
      link: d['productLink'] as String? ?? '',
      status: _mapStatus(d['status'] as String?),
      createdAt: (d['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  SuggestionStatus _mapStatus(String? value) => switch (value) {
    'approved' => SuggestionStatus.approved,
    'rejected' => SuggestionStatus.rejected,
    _ => SuggestionStatus.underReview,
  };
}