import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopverse/models/product.dart';

class WishlistProvider with ChangeNotifier {
  Map<String, Product> _items = {};

  WishlistProvider() {
    _loadFromPrefs();
  }

  Map<String, Product> get items => {..._items};

  int get itemCount => _items.length;

  bool isFavorite(String productId) {
    return _items.containsKey(productId);
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_items.map((key, value) => MapEntry(key, value.toJson())));
    await prefs.setString('wishlist_data', data);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('wishlist_data')) return;
    
    final data = json.decode(prefs.getString('wishlist_data')!) as Map<String, dynamic>;
    _items = data.map((key, value) => MapEntry(key, Product.fromJson(value)));
    notifyListeners();
  }

  void toggleWishlist(Product product) {
    if (_items.containsKey(product.id)) {
      _items.remove(product.id);
    } else {
      _items.putIfAbsent(product.id, () => product);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _saveToPrefs();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveToPrefs();
    notifyListeners();
  }
}
