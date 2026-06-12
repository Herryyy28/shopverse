import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<dynamic> products;
  final DateTime dateTime;
  final String status;
  final String userId;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
    required this.userId,
    this.status = 'Pending',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'products': products,
    'dateTime': dateTime.toIso8601String(),
    'status': status,
    'userId': userId,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    products: json['products'] ?? [],
    dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
    status: json['status'] ?? 'Pending',
    userId: json['userId'] ?? '',
  );
}

class OrderProvider with ChangeNotifier {
  List<OrderItem> _orders = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<OrderItem> get orders => [..._orders];

  OrderProvider() {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final snapshot = await _firestore.collection('orders').orderBy('dateTime', descending: true).get();
      _orders = snapshot.docs.map((doc) => OrderItem.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'status': newStatus});
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
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  // Real-time listener for dashboard updates
  Stream<List<OrderItem>> get ordersStream {
    return _firestore.collection('orders').orderBy('dateTime', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OrderItem.fromJson(doc.data())).toList();
    });
  }
}
