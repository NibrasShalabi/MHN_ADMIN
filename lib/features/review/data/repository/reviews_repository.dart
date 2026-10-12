import '../../domain/entities/app_review.dart';

abstract class ReviewsRepository {
  Future<List<AppReview>> getPendingReviews();
  Future<void> approve(String uid, {String? authorName});
  Future<void> reject(String uid);

  /// What customers see on the store, newest first.
  Future<List<AppReview>> getPublishedReviews();

  /// Takes a review off the store. The rating record stays, so the
  /// customer can't rate again for a second reward.
  Future<void> deletePublished(String uid);
}