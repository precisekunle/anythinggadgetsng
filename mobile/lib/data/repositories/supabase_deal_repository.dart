import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/deal_repository.dart';
import '../models/deal.dart';
import '../models/product.dart';

class SupabaseDealRepository implements DealRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<Map<String, dynamic>?> getActiveDeal() async {
    final response = await _client.rpc('get_active_deal_with_products');
    
    if (response == null) return null;

    final data = response as Map<String, dynamic>;
    final dealJson = data['deal'] as Map<String, dynamic>;
    final productsJson = data['products'] as List<dynamic>;

    return {
      'deal': Deal.fromJson(dealJson),
      'products': productsJson.map((p) => Product.fromJson(p)).toList(),
    };
  }
}
