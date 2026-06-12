import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryItem {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;

  CategoryItem({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconCode': iconCode,
    'colorValue': colorValue,
  };

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    iconCode: json['iconCode'] ?? Icons.category.codePoint,
    colorValue: json['colorValue'] ?? Colors.blue.value,
  );

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}

class CategoryProvider with ChangeNotifier {
  List<CategoryItem> _categories = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CategoryItem> get categories => [..._categories];

  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      if (snapshot.docs.isNotEmpty) {
        _categories = snapshot.docs.map((doc) => CategoryItem.fromJson(doc.data())).toList();
      } else {
        // Mock data fallback
        _categories = [
          CategoryItem(id: 'c1', name: 'Grocery', iconCode: Icons.fastfood.codePoint, colorValue: Colors.green.value),
          CategoryItem(id: 'c2', name: 'Fashion', iconCode: Icons.checkroom.codePoint, colorValue: Colors.blue.value),
          CategoryItem(id: 'c3', name: 'Electronics', iconCode: Icons.electrical_services.codePoint, colorValue: Colors.orange.value),
          CategoryItem(id: 'c4', name: 'Home', iconCode: Icons.home.codePoint, colorValue: Colors.brown.value),
          CategoryItem(id: 'c5', name: 'Beauty', iconCode: Icons.health_and_safety.codePoint, colorValue: Colors.pink.value),
          CategoryItem(id: 'c6', name: 'Toys', iconCode: Icons.toys.codePoint, colorValue: Colors.red.value),
          CategoryItem(id: 'c7', name: 'Sports', iconCode: Icons.sports_basketball.codePoint, colorValue: Colors.indigo.value),
          CategoryItem(id: 'c8', name: 'Automotive', iconCode: Icons.directions_car.codePoint, colorValue: Colors.blueGrey.value),
        ];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> addCategory(String name, IconData icon, Color color) async {
    final newCat = CategoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      iconCode: icon.codePoint,
      colorValue: color.value,
    );
    
    try {
      await _firestore.collection('categories').doc(newCat.id).set(newCat.toJson());
      _categories.add(newCat);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  // Real-time listener for categories
  Stream<List<CategoryItem>> get categoriesStream {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CategoryItem.fromJson(doc.data())).toList();
    });
  }
}
