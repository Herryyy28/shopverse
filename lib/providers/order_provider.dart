import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopverse/models/order_model.dart';
import 'package:shopverse/models/cart_item.dart';
import 'package:shopverse/models/product.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  List<OrderModel> get orders => [..._orders];

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
      OrderModel(
        id: 'ORD-8821',
        userId: 'u1',
        items: [
          CartItem(
            product: Product(
              id: 'p0',
              name: 'Neon Velocity G7',
              price: 1890.0,
              imageUrl: 'https://images.unsplash.com/photo-1605405748283-9463ae74c65e?w=200',
              category: 'Shoes',
              description: 'Awesome sneakers',
              rating: 4.5,
              reviews: 120,
            ),
            quantity: 1,
          ),
          CartItem(
            product: Product(
              id: 'p1',
              name: 'Sport Socks',
              price: 130.0,
              imageUrl: 'https://images.unsplash.com/photo-1582966772680-860e372bb558?w=200',
              category: 'Accessories',
              description: 'Comfortable socks',
              rating: 4.0,
              reviews: 40,
            ),
            quantity: 2,
          ),
        ],
        totalAmount: 2150.0,
        deliveryFee: 25.0,
        tax: 15.0,
        deliveryAddress: '123 Main St, Apartment 4B\nNew York, NY 10001',
        status: OrderStatus.processing,
        paymentMethod: 'Credit Card (Stripe)',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      OrderModel(
        id: 'ORD-7742',
        userId: 'u1',
        items: [
          CartItem(
            product: Product(
              id: 'p2',
              name: 'Amul Taaza 1L',
              price: 135.0,
              imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200',
              category: 'Grocery',
              description: 'Fresh milk',
              rating: 4.8,
              reviews: 200,
            ),
            quantity: 4,
          ),
        ],
        totalAmount: 540.0,
        deliveryFee: 10.0,
        tax: 0.0,
        deliveryAddress: '123 Main St, Apartment 4B\nNew York, NY 10001',
        status: OrderStatus.delivered,
        paymentMethod: 'Wallet',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
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
      _orders = snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (_orders.isEmpty) _loadMockOrders();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final current = _orders[index];
      _orders[index] = OrderModel(
        id: current.id,
        userId: current.userId,
        items: current.items,
        totalAmount: current.totalAmount,
        deliveryFee: current.deliveryFee,
        tax: current.tax,
        discount: current.discount,
        deliveryAddress: current.deliveryAddress,
        status: newStatus,
        paymentMethod: current.paymentMethod,
        createdAt: current.createdAt,
        trackingId: current.trackingId,
      );
      notifyListeners();
    }

    try {
      if (Firebase.apps.isNotEmpty) {
        await _firestore.collection('orders').doc(orderId).update({'status': newStatus.toString().split('.').last});
      }
    } catch (e) {
      debugPrint('Error syncing status to Firebase: $e');
    }
  }

  Stream<List<OrderModel>> get ordersStream {
    try {
      if (Firebase.apps.isEmpty) return Stream.value(_orders);
      return _firestore.collection('orders').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
      });
    } catch (e) {
      return Stream.value(_orders);
    }
  }

  Future<String> addOrder({
    required List<CartItem> items,
    required double totalAmount,
    required double deliveryFee,
    required double tax,
    required double discount,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final newOrder = OrderModel(
      id: orderId,
      userId: Firebase.apps.isNotEmpty ? _auth.currentUser?.uid ?? 'guest' : 'guest',
      items: items,
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
      tax: tax,
      discount: discount,
      deliveryAddress: deliveryAddress,
      status: OrderStatus.confirmed,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
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
    return orderId;
  }
}
