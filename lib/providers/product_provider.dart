import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/services/firebase_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> get products => [..._products];

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      if (snapshot.docs.isNotEmpty) {
        _products = snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
      } else {
        // Mock data fallback for demonstration if Firestore is empty
        _products = [
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
        ];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).set(product.toJson());
      _products.insert(0, product);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Stream<List<Product>> get productsStream {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
    });
  }
}
