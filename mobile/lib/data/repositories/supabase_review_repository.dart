import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review.dart';

class SupabaseReviewRepository implements ReviewRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<Review>> getProductReviews(String productId) async {
    final response = await _client
        .from('reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);
    
    final data = response as List<dynamic>;
    return data.map((json) => Review.fromJson(json)).toList();
  }

  @override
  Future<void> submitReview(Review review) async {
    await _client.from('reviews').upsert(review.toJson());
  }

  Future<String> uploadReviewImage(String filePath) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'reviews/$fileName';
    
    await _client.storage.from('review-images').upload(
      path,
      File(filePath),
    );

    return _client.storage.from('review-images').getPublicUrl(path);
  }

  @override
  Future<double> getAverageRating(String productId) async {
    final response = await _client
        .from('reviews')
        .select('rating')
        .eq('product_id', productId);
    
    final data = response as List<dynamic>;
    if (data.isEmpty) return 0.0;
    
    final total = data.fold<int>(0, (sum, item) => sum + (item['rating'] as int));
    return total / data.length;
  }
}
