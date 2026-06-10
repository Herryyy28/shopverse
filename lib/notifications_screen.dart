import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockNotifications = [
      {
        'title': 'Order Delivered! 📦',
        'body': 'Your order #SV-1024 has been delivered. Rate your experience!',
        'time': '2 mins ago',
        'type': 'order'
      },
      {
        'title': 'Flash Sale: 50% OFF! 🔥',
        'body': 'Huge discounts on fresh fruits and vegetables. Grab them now!',
        'time': '1 hour ago',
        'type': 'promo'
      },
      {
        'title': 'Wallet Credited 💰',
        'body': '₹50 Verse Points added to your account for your last purchase.',
        'time': '3 hours ago',
        'type': 'wallet'
      },
      {
        'title': 'New Store Near You 🏪',
        'body': 'ShopVerse is now live in your sector with faster delivery!',
        'time': 'Yesterday',
        'type': 'info'
      },
      {
        'title': 'Missed your favorites?',
        'body': 'The items in your wishlist are back in stock. Shop now!',
        'time': '2 days ago',
        'type': 'promo'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final note = mockNotifications[index];
          IconData icon;
          Color color;
          
          switch(note['type']) {
            case 'order': icon = Icons.shopping_bag; color = Colors.green; break;
            case 'promo': icon = Icons.local_offer; color = const Color(0xFFFF3232); break;
            case 'wallet': icon = Icons.account_balance_wallet; color = Colors.orange; break;
            default: icon = Icons.info; color = Colors.blue;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 20),
              ),
              title: Text(
                note['title']!,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(note['body']!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(note['time']!, style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
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
