import 'package:flutter/material.dart';
import 'package:shopverse/models/product.dart';

class CompareProvider with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => [..._items];

  bool get canCompare => _items.length < 3;

  bool isComparing(String id) => _items.any((p) => p.id == id);

  String? addProduct(Product product) {
    if (isComparing(product.id)) {
      removeProduct(product.id);
      return "Removed from comparison";
    }

    if (_items.length >= 3) {
      return "You can compare up to 3 products at a time";
    }

    if (_items.isNotEmpty && _items.first.category != product.category) {
      return "You can only compare products of the same category";
    }

    _items.add(product);
    notifyListeners();
    return null;
  }

  void removeProduct(String id) {
    _items.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
