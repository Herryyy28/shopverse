import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopverse/models/user_model.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> get users => _users;

  UserProvider() {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      // In a real app, this fetches from the 'users' collection
      final snapshot = await _firestore.collection('users').get();
      
      if (snapshot.docs.isEmpty) {
        // Fallback to mock data if collection is empty for demonstration
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
      } else {
        _users = snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  Stream<List<UserModel>> get usersStream {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    });
  }
}
