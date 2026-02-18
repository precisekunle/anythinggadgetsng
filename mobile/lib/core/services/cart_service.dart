import 'package:flutter/foundation.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final ValueNotifier<List<CartItem>> cartItemsNotifier = ValueNotifier([]);

  List<CartItem> get items => cartItemsNotifier.value;

  double get totalAmount {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }
  
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  void addToCart(Product product, {int quantity = 1}) {
    final currentItems = List<CartItem>.from(items);
    final existingIndex = currentItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      currentItems[existingIndex].quantity += quantity;
    } else {
      currentItems.add(CartItem(product: product, quantity: quantity));
    }
    
    cartItemsNotifier.value = currentItems;
  }

  void removeFromCart(String productId) {
    final currentItems = List<CartItem>.from(items);
    currentItems.removeWhere((item) => item.product.id == productId);
    cartItemsNotifier.value = currentItems;
  }
  
  void updateQuantity(String productId, int quantity) {
    final currentItems = List<CartItem>.from(items);
    final index = currentItems.indexWhere((item) => item.product.id == productId);
    
    if (index >= 0) {
      if (quantity <= 0) {
        removeFromCart(productId);
      } else {
        currentItems[index].quantity = quantity;
        cartItemsNotifier.value = currentItems;
      }
    }
  }

  void clearCart() {
    cartItemsNotifier.value = [];
  }
}
