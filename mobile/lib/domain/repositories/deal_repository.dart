import '../models/deal.dart';
import '../models/product.dart';

abstract class DealRepository {
  Future<Map<String, dynamic>?> getActiveDeal();
}
