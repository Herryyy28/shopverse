import 'package:flutter/material.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'John Doe',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'johndoe@example.com',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            _buildProfileItem(Icons.shopping_bag_outlined, 'My Orders', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
            }),
            _buildProfileItem(Icons.favorite_outline, 'My Wishlist', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
            }),
            _buildProfileItem(Icons.location_on_outlined, 'Delivery Addresses', () {}),
            _buildProfileItem(Icons.payment_outlined, 'Payment Methods', () {}),
            _buildProfileItem(Icons.notifications_none_outlined, 'Notifications', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            }),
            _buildProfileItem(Icons.settings_outlined, 'Settings', () {}),
            _buildProfileItem(Icons.help_outline, 'Help Center', () {}),
            const Divider(height: 32),
            _buildProfileItem(Icons.logout, 'Logout', () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }, textColor: Colors.red),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap, {Color? textColor}) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
