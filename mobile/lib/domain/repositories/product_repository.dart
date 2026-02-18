import '../../data/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<List<Product>> getProductsByCategory(String category);
  Future<List<Product>> getDealProducts();
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> filterProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  });
}
