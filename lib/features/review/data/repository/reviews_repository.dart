import '../../domain/entities/app_review.dart';

abstract class ReviewsRepository {
  Future<List<AppReview>> getPendingReviews();
  Future<void> approve(String uid, {String? authorName});
  Future<void> reject(String uid);
}