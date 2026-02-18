import '../models/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getProductReviews(String productId);
  Future<void> submitReview(Review review);
  Future<double> getAverageRating(String productId);
}
