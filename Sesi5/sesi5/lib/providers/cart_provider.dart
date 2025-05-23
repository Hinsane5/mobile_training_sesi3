import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;

  CartProvider() {
    loadCart();
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items[productId] = CartItem(
        id: _items[productId]!.id,
        title: _items[productId]!.title,
        price: _items[productId]!.price,
        quantity: _items[productId]!.quantity + 1,
      );
    } else {
      _items[productId] = CartItem(
        id: productId,
        title: title,
        price: price,
        quantity: 1,
      );
    }
    saveCart();
    notifyListeners();
  }

  double get totalPrice =>
      _items.values.fold(0, (sum, item) => sum + (item.price * item.quantity));

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartMap = _items.map((key, value) => MapEntry(key, value.toJson()));
    final jsonString = jsonEncode(cartMap);
    await prefs.setString('cart_items', jsonString);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cart_items');
    if (jsonString == null) return;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    _items = jsonMap.map((key, value) => MapEntry(key, CartItem.fromJson(value)));
    notifyListeners();
  }
}
