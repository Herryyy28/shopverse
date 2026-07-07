import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopverse/models/user_model.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];
  
  // Use lazy getter to avoid crash during provider initialization
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<UserModel> get users => _users;

  UserProvider() {
    _safeFetchUsers();
  }

  Future<void> _safeFetchUsers() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await fetchUsers();
      } else {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Firebase not ready for users: $e');
      _loadMockData();
    }
  }

  void _loadMockData() {
    _users = [
      UserModel(
        uid: 'u1',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        role: 'customer',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      UserModel(
        uid: 'u2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        phone: '0987654321',
        role: 'customer',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      UserModel(
        uid: 'u3',
        name: 'Admin User',
        email: 'admin@shopverse.com',
        role: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      UserModel(
        uid: 'v_fashion',
        name: 'Apex Footwear Store',
        email: 'vendor1@shopverse.com',
        role: 'vendor',
        storeName: 'Apex Footwear',
        storeBannerUrl: 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=800',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      UserModel(
        uid: 'v_grocery',
        name: 'Fresh Mart Official',
        email: 'vendor2@shopverse.com',
        role: 'vendor',
        storeName: 'Fresh Mart',
        storeBannerUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
      UserModel(
        uid: 'v_tech',
        name: 'Tech Haven Shop',
        email: 'vendor3@shopverse.com',
        role: 'vendor',
        storeName: 'Tech Haven',
        storeBannerUrl: 'https://images.unsplash.com/photo-1550009158-9efff6c97068?w=800',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      if (snapshot.docs.isNotEmpty) {
        _users = snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
        notifyListeners();
      } else {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      _loadMockData();
    }
  }

  Stream<List<UserModel>> get usersStream {
    try {
      if (Firebase.apps.isEmpty) return Stream.value(_users);
      return _firestore.collection('users').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      });
    } catch (e) {
      return Stream.value(_users);
    }
  }
}
