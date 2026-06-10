import 'package:flutter/material.dart';

class AdminStats {
  final int totalUsers;
  final int totalOrders;
  final double totalRevenue;
  final int totalProducts;

  AdminStats({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalProducts,
  });
}

class AdminProvider with ChangeNotifier {
  AdminStats _stats = AdminStats(
    totalUsers: 1250,
    totalOrders: 4500,
    totalRevenue: 854000.50,
    totalProducts: 320,
  );

  AdminStats get stats => _stats;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  void toggleAdminMode() {
    _isAdmin = !_isAdmin;
    notifyListeners();
  }

  // Future<void> fetchStats() async { ... }
}
