import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/address_repository.dart';
import '../models/user_address.dart';

class SupabaseAddressRepository implements AddressRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<UserAddress>> getAddresses(String userId) async {
    final response = await _client
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    
    final data = response as List<dynamic>;
    return data.map((json) => UserAddress.fromJson(json)).toList();
  }

  @override
  Future<void> addAddress(UserAddress address) async {
    await _client.from('addresses').insert(address.toJson());
  }

  @override
  Future<void> updateAddress(UserAddress address) async {
    await _client
        .from('addresses')
        .update(address.toJson())
        .eq('id', address.id);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await _client.from('addresses').delete().eq('id', addressId);
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    // Transaction-like behavior
    await _client
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', userId);
    
    await _client
        .from('addresses')
        .update({'is_default': true})
        .eq('id', addressId);
  }
}
