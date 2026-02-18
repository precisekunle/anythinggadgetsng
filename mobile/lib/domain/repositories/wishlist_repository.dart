import '../models/product.dart';

abstract class WishlistRepository {
  Future<List<Product>> getWishlist(String userId);
  Future<void> addToWishlist(String userId, String productId);
  Future<void> removeFromWishlist(String userId, String productId);
  Future<bool> isInWishlist(String userId, String productId);
}
