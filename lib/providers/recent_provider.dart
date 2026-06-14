import 'package:flutter/material.dart';
import 'package:shopverse/models/product.dart';

class RecentProvider with ChangeNotifier {
  final List<Product> _recentlyViewed = [];

  List<Product> get recentlyViewed => [..._recentlyViewed];

  void addProduct(Product product) {
    // Remove if already exists to move it to the front
    _recentlyViewed.removeWhere((p) => p.id == product.id);
    _recentlyViewed.insert(0, product);
    
    // Limit to last 10 items
    if (_recentlyViewed.length > 10) {
      _recentlyViewed.removeLast();
    }
    notifyListeners();
  }
}
