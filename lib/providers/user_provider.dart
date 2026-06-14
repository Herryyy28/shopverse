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
