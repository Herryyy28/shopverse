import 'package:flutter/material.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<dynamic> products;
  final DateTime dateTime;
  final String status;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
    this.status = 'Delivered',
  });
}

class OrderProvider with ChangeNotifier {
  final List<OrderItem> _orders = [];

  List<OrderItem> get orders => [..._orders];

  String addOrder(double total, List<dynamic> cartProducts) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    _orders.insert(
      0,
      OrderItem(
        id: newId,
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
        status: 'Pending', // Changed default to Pending for better admin flow
      ),
    );
    notifyListeners();
    return newId;
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = OrderItem(
        id: _orders[index].id,
        amount: _orders[index].amount,
        products: _orders[index].products,
        dateTime: _orders[index].dateTime,
        status: newStatus,
      );
      notifyListeners();
    }
  }
}
