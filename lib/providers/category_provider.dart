import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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
    colorValue: json['colorValue'] ?? Colors.blue.toARGB32(),
  );

  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}

class CategoryProvider with ChangeNotifier {
  List<CategoryItem> _categories = [];
  
  // Use lazy getter to avoid "No Firebase App" crash during provider initialization
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<CategoryItem> get categories => [..._categories];

  CategoryProvider() {
    _safeFetchCategories();
  }

  Future<void> _safeFetchCategories() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await fetchCategories();
      } else {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Firebase not ready for categories: $e');
      _loadMockData();
    }
  }

  void _loadMockData() {
    _categories = [
      CategoryItem(id: 'c1', name: 'Grocery', iconCode: Icons.fastfood.codePoint, colorValue: Colors.green.toARGB32()),
      CategoryItem(id: 'c2', name: 'Fashion', iconCode: Icons.checkroom.codePoint, colorValue: Colors.blue.toARGB32()),
      CategoryItem(id: 'c3', name: 'Electronics', iconCode: Icons.electrical_services.codePoint, colorValue: Colors.orange.toARGB32()),
      CategoryItem(id: 'c4', name: 'Home', iconCode: Icons.home.codePoint, colorValue: Colors.brown.toARGB32()),
      CategoryItem(id: 'c5', name: 'Beauty', iconCode: Icons.health_and_safety.codePoint, colorValue: Colors.pink.toARGB32()),
      CategoryItem(id: 'c6', name: 'Toys', iconCode: Icons.toys.codePoint, colorValue: Colors.red.toARGB32()),
      CategoryItem(id: 'c7', name: 'Sports', iconCode: Icons.sports_basketball.codePoint, colorValue: Colors.indigo.toARGB32()),
      CategoryItem(id: 'c8', name: 'Automotive', iconCode: Icons.directions_car.codePoint, colorValue: Colors.blueGrey.toARGB32()),
    ];
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      if (snapshot.docs.isNotEmpty) {
        _categories = snapshot.docs.map((doc) => CategoryItem.fromJson(doc.data())).toList();
        notifyListeners();
      } else {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      _loadMockData();
    }
  }

  Future<void> addCategory(String name, IconData icon, Color color) async {
    final newCat = CategoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      iconCode: icon.codePoint,
      colorValue: color.toARGB32(),
    );
    
    try {
      await _firestore.collection('categories').doc(newCat.id).set(newCat.toJson());
      _categories.add(newCat);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }

  Stream<List<CategoryItem>> get categoriesStream {
    try {
      if (Firebase.apps.isEmpty) return Stream.value(_categories);
      return _firestore.collection('categories').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => CategoryItem.fromJson(doc.data())).toList();
      });
    } catch (e) {
      return Stream.value(_categories);
    }
  }
}
