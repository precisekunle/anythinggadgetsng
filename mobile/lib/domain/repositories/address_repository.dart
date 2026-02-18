import '../models/user_address.dart';

abstract class AddressRepository {
  Future<List<UserAddress>> getAddresses(String userId);
  Future<void> addAddress(UserAddress address);
  Future<void> updateAddress(UserAddress address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String userId, String addressId);
}
