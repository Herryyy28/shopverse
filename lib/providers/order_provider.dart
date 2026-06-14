import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/order_item.dart';

class OrderProvider with ChangeNotifier {
  List<OrderItem> _orders = [];

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  List<OrderItem> get orders => [..._orders];

  OrderProvider() {
    _safeFetchOrders();
  }

  Future<void> _safeFetchOrders() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await fetchOrders();
      } else {
        _loadMockOrders();
      }
    } catch (e) {
      debugPrint('Firebase not ready for orders: $e');
      _loadMockOrders();
    }
  }

  void _loadMockOrders() {
    _orders = [
      OrderItem(
        id: 'ORD-8821',
        amount: 2150.0,
        products: [
          {'name': 'Neon Velocity G7', 'quantity': 1, 'price': 1890.0},
          {'name': 'Sport Socks', 'quantity': 2, 'price': 130.0},
        ],
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        userId: 'u1',
        status: 'Processing',
      ),
      OrderItem(
        id: 'ORD-7742',
        amount: 540.0,
        products: [
          {'name': 'Amul Taaza 1L', 'quantity': 4, 'price': 135.0},
        ],
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'u2',
        status: 'Delivered',
      ),
      OrderItem(
        id: 'ORD-9910',
        amount: 1200.0,
        products: [
          {'name': 'Wireless Mouse', 'quantity': 1, 'price': 1200.0},
        ],
        dateTime: DateTime.now().subtract(const Duration(minutes: 45)),
        userId: 'u3',
        status: 'Pending',
      ),
    ];
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('dateTime', descending: true)
          .get();
      _orders = snapshot.docs.map((doc) => OrderItem.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (_orders.isEmpty) _loadMockOrders();
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    // Update local state first for instant UI feedback
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final current = _orders[index];
      _orders[index] = OrderItem(
        id: current.id,
        amount: current.amount,
        products: current.products,
        dateTime: current.dateTime,
        userId: current.userId,
        status: newStatus,
      );
      notifyListeners();
    }

    try {
      if (Firebase.apps.isNotEmpty) {
        await _firestore.collection('orders').doc(orderId).update({'status': newStatus});
      }
    } catch (e) {
      debugPrint('Error syncing status to Firebase: $e');
    }
  }

  Stream<List<OrderItem>> get ordersStream {
    try {
      if (Firebase.apps.isEmpty) return Stream.value(_orders);
      return _firestore.collection('orders').orderBy('dateTime', descending: true).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => OrderItem.fromJson(doc.data())).toList();
      });
    } catch (e) {
      return Stream.value(_orders);
    }
  }

  Future<void> addOrder(double total, List<dynamic> cartItems) async {
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final newOrder = OrderItem(
      id: orderId,
      amount: total,
      products: cartItems,
      dateTime: DateTime.now(),
      userId: _auth.currentUser?.uid ?? 'guest',
    );

    _orders.insert(0, newOrder);
    notifyListeners();

    try {
      if (Firebase.apps.isNotEmpty) {
        await _firestore.collection('orders').doc(orderId).set(newOrder.toJson());
      }
    } catch (e) {
      debugPrint('Error saving order to Firebase: $e');
    }
  }
}
