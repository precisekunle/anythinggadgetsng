import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product.dart';

class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<Product>> getProducts() async {
    final response = await _client.from('products').select().order('created_at');
    final data = response as List<dynamic>;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _client.from('products').select().eq('id', id).single();
      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await _client.from('products').select().eq('category', category);
    final data = response as List<dynamic>;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<List<Product>> getDealProducts() async {
    final response = await _client
        .from('products')
        .select()
        .limit(5); // For now, just a limit
    final data = response as List<dynamic>;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final response = await _client.rpc('search_products_fts', params: {
      'search_query': query,
    });
    final data = response as List<dynamic>;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<List<Product>> getRelatedProducts(String productId, {int limit = 4}) async {
    final response = await _client.rpc('get_related_products', params: {
      'p_id': productId,
      'p_limit': limit,
    });
    final data = response as List<dynamic>;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<List<Product>> filterProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    var query = _client.from('products').select();

    if (category != null) {
      query = query.eq('category', category);
    }
    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }
    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }

    if (sortBy != null) {
      final parts = sortBy.split(':');
      final column = parts[0];
      final ascending = parts.length > 1 ? parts[1] == 'asc' : false;
      query = query.order(column, ascending: ascending);
    } else {
      query = query.order('created_at');
    }

    final response = await query;
    final data = response as List<dynamic>;
    return data.map((json) => Product.fromJson(json)).toList();
  }
}
