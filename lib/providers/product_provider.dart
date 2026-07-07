import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopverse/models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  
  // Use lazy getter to avoid "No Firebase App" crash during provider initialization
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<Product> get products => [..._products];
  
  List<Product> getProductsByVendor(String vendorId) {
    return _products.where((p) => p.vendorId == vendorId).toList();
  }

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
        vendorId: 'v_fashion',
        vendorName: 'Apex Footwear',
      ),
      Product(
        id: 'p1',
        name: 'Amul Taaza Milk',
        description: 'Fresh toned milk',
        price: 27.0,
        oldPrice: 30.0,
        imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=800',
        category: 'Dairy',
        unit: '500 ml',
        rating: 4.8,
        isVeg: true,
        vendorId: 'v_grocery',
        vendorName: 'Fresh Mart',
      ),
      Product(
        id: 'p2',
        name: 'Fortune Sunlite Sunflower Oil',
        brand: 'Fortune',
        description: 'Light and healthy sunflower oil for daily cooking.',
        price: 145.0,
        oldPrice: 170.0,
        imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=800',
        category: 'Grocery',
        unit: '1 Litre',
        rating: 4.5,
        isVeg: true,
        vendorId: 'v_grocery',
        vendorName: 'Fresh Mart',
      ),
      Product(
        id: 'p3',
        name: 'Aashirvaad Superior MP Atta',
        brand: 'Aashirvaad',
        description: 'Premium whole wheat flour for soft rotis.',
        price: 245.0,
        oldPrice: 280.0,
        imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=800',
        category: 'Grocery',
        unit: '5 kg',
        rating: 4.7,
        isVeg: true,
        vendorId: 'v_grocery',
        vendorName: 'Fresh Mart',
      ),
      Product(
        id: 'p4',
        name: 'Aura Pro Wireless Headphones - Midnight Purple',
        brand: 'AURA',
        description: 'Immersive sound with active noise cancellation and 40-hour battery life.',
        price: 299.0,
        oldPrice: 349.0,
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
        category: 'Electronics',
        rating: 4.8,
        reviews: 1240,
        vendorId: 'v_tech',
        vendorName: 'Tech Haven',
      ),
      Product(
        id: 'p5',
        name: 'Chronos Classic Steel Edition',
        brand: 'CHRONOS',
        description: 'Timeless design meets modern precision. Sapphire glass and genuine leather strap.',
        price: 185.0,
        oldPrice: 220.0,
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        category: 'Accessories',
        rating: 4.7,
        reviews: 850,
        vendorId: 'v_fashion',
        vendorName: 'Apex Footwear',
      ),
      Product(
        id: 'p6',
        name: 'Swift-Run Nitro Pro - Crimson',
        brand: 'SWIFT',
        description: 'Ultra-lightweight running shoes with Nitro-foam technology.',
        price: 120.0,
        oldPrice: 150.0,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
        category: 'Footwear',
        rating: 4.9,
        reviews: 2100,
        vendorId: 'v_fashion',
        vendorName: 'Apex Footwear',
      ),
      Product(
        id: 'p7',
        name: 'Horizon Wayfarer - Tortoise Shell',
        brand: 'HORIZON',
        description: 'Handcrafted acetate frames with polarized lenses for 100% UV protection.',
        price: 75.0,
        oldPrice: 95.0,
        imageUrl: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800',
        category: 'Accessories',
        rating: 4.6,
        reviews: 540,
        vendorId: 'v_fashion',
        vendorName: 'Apex Footwear',
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

  void refreshProducts() {
    _safeFetchProducts();
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
