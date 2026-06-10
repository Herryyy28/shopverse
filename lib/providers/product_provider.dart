import 'package:flutter/material.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/services/firebase_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [
    Product(
      id: 'p0',
      name: 'Neon Velocity G7 Pro',
      brand: 'APEX FOOTWEAR',
      description: 'Engineered for the neon-lit streets and high-velocity performance...',
      price: 189.0,
      oldPrice: 245.0,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
      category: 'Footwear',
      rating: 4.9,
      reviews: 2400,
      isVeg: true,
    ),
    Product(
      id: 'p1',
      name: 'Amul Taaza Milk',
      description: 'Fresh toned milk',
      price: 27.0,
      oldPrice: 30.0,
      imageUrl: 'https://www.amul.com/files/products/Taaza_1L_Front.jpg',
      category: 'Dairy',
      unit: '500 ml',
      rating: 4.8,
      isVeg: true,
    ),
    Product(
      id: 'p2',
      name: 'Fortune Sunlite Sunflower Oil',
      description: 'Refined sunflower oil',
      price: 145.0,
      oldPrice: 175.0,
      imageUrl: 'https://m.media-amazon.com/images/I/71p0WfB6LHL._SL1500_.jpg',
      category: 'Grocery',
      unit: '1 L',
      rating: 4.5,
      isVeg: true,
    ),
  ];

  List<Product> get products => [..._products];

  Future<void> addProduct(Product product) async {
    // 1. Save to Firestore (via FirebaseService)
    await FirebaseService.saveProduct(product.toJson());
    
    // 2. Update local state
    _products.insert(0, product);
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    // Fetch from Firebase if needed
    // final data = await FirebaseService.fetchProducts();
    // _products = data.map((item) => Product.fromJson(item)).toList();
    // notifyListeners();
  }
}
