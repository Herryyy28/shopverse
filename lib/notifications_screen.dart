import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        itemCount: 10,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.withOpacity(0.1),
              child: const Icon(Icons.notifications_active, color: Colors.deepPurple),
            ),
            title: Text(
              index % 2 == 0 ? 'Order Shipped!' : 'Big Sale Tomorrow!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              index % 2 == 0 
                ? 'Your order #SV1234$index has been shipped and will arrive soon.' 
                : 'Get ready for our mega sale! Up to 80% off on all categories.',
            ),
            trailing: const Text('2h ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
            onTap: () {},
          );
        },
      ),
    );
  }
}
