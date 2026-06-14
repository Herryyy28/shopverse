import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopverse/models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  
  // Use lazy getter to avoid "No Firebase App" crash during provider initialization
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<Product> get products => [..._products];

  ProductProvider() {
    _safeFetchProducts();
  }

  Future<void> _safeFetchProducts() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await fetchProducts();
      } else {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Firebase not ready for products: $e');
      _loadMockData();
    }
  }

  void _loadMockData() {
    _products = [
      Product(
        id: 'p0',
        name: 'Neon Velocity G7 Pro',
        brand: 'APEX FOOTWEAR',
        description: 'Engineered for the neon-lit streets and high-velocity performance...',
        price: 189.0,
        oldPrice: 245.0,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
        images: [
          'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800',
          'https://images.unsplash.com/photo-1605405748283-9463ae74c65e?w=800'
        ],
        category: 'Footwear',
        rating: 4.9,
        reviews: 2400,
        isVeg: true,
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        arModelUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
        view360Url: 'true',
        variants: [
          ProductVariant(id: 'v1', name: 'Color', options: ['Neon Green', 'Space Black', 'Solar Red']),
          ProductVariant(id: 'v2', name: 'Size', options: ['UK 7', 'UK 8', 'UK 9', 'UK 10']),
        ],
        specifications: {
          'Material': 'Synthetic Knit',
          'Sole': 'Aerogel Reactive',
          'Weight': '210g',
          'Style': 'Low-top'
        },
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
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      if (snapshot.docs.isNotEmpty) {
        _products = snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
        notifyListeners();
      } else {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      _loadMockData();
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

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toJson());
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      // Update local state anyway if Firestore fails (mock mode)
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _products[index] = product;
        notifyListeners();
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting product: $e');
    }
  }

  Stream<List<Product>> get productsStream {
    try {
      if (Firebase.apps.isEmpty) return Stream.value(_products);
      return _firestore.collection('products').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
      });
    } catch (e) {
      return Stream.value(_products);
    }
  }
}
