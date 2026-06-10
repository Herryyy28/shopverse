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

  void addOrder(double total, List<dynamic> cartProducts) {
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
