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
    totalUsers: 0,
    totalOrders: 0,
    totalRevenue: 0.0,
    totalProducts: 0,
  );

  AdminStats get stats => _stats;

  void updateStats({
    required int totalUsers,
    required int totalOrders,
    required double totalRevenue,
    required int totalProducts,
  }) {
    _stats = AdminStats(
      totalUsers: totalUsers,
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      totalProducts: totalProducts,
    );
    notifyListeners();
  }

  bool _isAdmin = true; // Set to true for admin access during development
  bool get isAdmin => _isAdmin;

  void toggleAdminMode() {
    _isAdmin = !_isAdmin;
    notifyListeners();
  }

  // Future<void> fetchStats() async { ... }
}
