import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shop.dart';
import '../models/product.dart';

class ShopRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Shop> getShopById(String shopId) async {
    final response = await _client
        .from('shops')
        .select()
        .eq('id', shopId)
        .single();
    
    return Shop.fromJson(response);
  }

  Future<List<Product>> getShopProducts(String shopId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('shop_id', shopId);
    
    final List<dynamic> data = response;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Shop>> getShops() async {
    final response = await _client.from('shops').select();
    final List<dynamic> data = response;
    return data.map((json) => Shop.fromJson(json)).toList();
  }
}
