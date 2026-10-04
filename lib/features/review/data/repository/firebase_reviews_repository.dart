import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_review.dart';
import 'reviews_repository.dart';

class FirebaseReviewsRepository implements ReviewsRepository {
  final FirebaseFirestore _db;

  FirebaseReviewsRepository(this._db);

  @override
  Future<List<AppReview>> getPendingReviews() async {
    final snap = await _db
        .collection('ratings')
        .where('isVisible', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((doc) {
      final d = doc.data();
      return AppReview(
        uid: doc.id,
        stars: d['stars'] as int? ?? 5,
        comment: d['comment'] as String?,
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isVisible: false,
      );
    }).toList();
  }

  /// نقل التقييم من ratings → reviews ويعمله visible
  @override
  Future<void> approve(String uid, {String? authorName}) async {
    final ratingDoc = await _db.collection('ratings').doc(uid).get();
    if (!ratingDoc.exists) return;

    final d = ratingDoc.data()!;
    final batch = _db.batch();

    // أضيف لـ reviews collection
    batch.set(_db.collection('reviews').doc(uid), {
      'authorName': authorName ?? 'مستخدم',
      'stars': d['stars'],
      'comment': d['comment'],
      'imageUrl': d['imageUrl'],
      'isVisible': true,
      'createdAt': d['createdAt'],
    });

    // عدّل ratings ليصير isVisible true
    batch.update(_db.collection('ratings').doc(uid), {'isVisible': true});

    await batch.commit();
  }

  /// رفض التقييم — نحذفه من ratings
  @override
  Future<void> reject(String uid) async {
    await _db.collection('ratings').doc(uid).delete();
  }
}