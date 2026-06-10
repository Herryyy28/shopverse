import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String? imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.imageUrl,
  });

  static List<CategoryModel> get dummyCategories => [
    CategoryModel(id: 'c1', name: 'Veggies', icon: Icons.eco, color: Colors.green),
    CategoryModel(id: 'c2', name: 'Dairy', icon: Icons.water_drop, color: Colors.blue),
    CategoryModel(id: 'c3', name: 'Snacks', icon: Icons.fastfood, color: Colors.orange),
    CategoryModel(id: 'c4', name: 'Drinks', icon: Icons.local_drink, color: Colors.cyan),
    CategoryModel(id: 'c5', name: 'Beauty', icon: Icons.face, color: Colors.pink),
    CategoryModel(id: 'c6', name: 'Home', icon: Icons.home, color: Colors.indigo),
    CategoryModel(id: 'c7', name: 'Pharma', icon: Icons.medication, color: Colors.red),
    CategoryModel(id: 'c8', name: 'Bakery', icon: Icons.bakery_dining, color: Colors.brown),
  ];
}
