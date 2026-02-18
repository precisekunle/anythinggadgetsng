import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../models/product.dart';

class SupabaseWishlistRepository implements WishlistRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<Product>> getWishlist(String userId) async {
    final response = await _client
        .from('wishlist')
        .select('products (*)')
        .eq('user_id', userId);
    
    final List<dynamic> data = response;
    return data.map((item) => Product.fromJson(item['products'])).toList();
  }

  @override
  Future<void> addToWishlist(String userId, String productId) async {
    await _client.from('wishlist').upsert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    await _client
        .from('wishlist')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  @override
  Future<bool> isInWishlist(String userId, String productId) async {
    final response = await _client
        .from('wishlist')
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();
    
    return response != null;
  }
}
