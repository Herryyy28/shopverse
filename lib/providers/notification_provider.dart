import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime sentAt;
  final String type; // 'broadcast', 'order', 'promo'

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.sentAt,
    this.type = 'broadcast',
  });
}

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  NotificationProvider() {
    _loadNotifications();
  }

  void _loadNotifications() {
    // Mock initial notifications
    _notifications = [
      AppNotification(
        id: '1',
        title: 'Welcome to ShopVerse Admin',
        body: 'You can now manage products, orders and users from this panel.',
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        type: 'info',
      ),
    ];
    notifyListeners();
  }

  Future<void> addNotification(String title, String body, {String type = 'broadcast'}) async {
    final newNotif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      sentAt: DateTime.now(),
      type: type,
    );
    _notifications.insert(0, newNotif);
    notifyListeners();
    
    // In a real app, you might also persist this to Firestore
  }
}
