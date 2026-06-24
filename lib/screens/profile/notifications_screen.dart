import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProv = Provider.of<NotificationProvider>(context);
    final notifications = notifProv.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notification History', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications sent yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final note = notifications[index];
                IconData icon;
                Color color;
                
                switch(note.type) {
                  case 'order': icon = Icons.shopping_bag; color = Colors.green; break;
                  case 'promo': icon = Icons.local_offer; color = const Color(0xFFFF3232); break;
                  case 'wallet': icon = Icons.account_balance_wallet; color = Colors.orange; break;
                  case 'broadcast': icon = Icons.campaign; color = Colors.purple; break;
                  default: icon = Icons.info; color = Colors.blue;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.1),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(note.body, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMM d, h:mm a').format(note.sentAt),
                          style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
    );
  }
}
