import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    const themeColor = Color(0xFFFF3232);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        leading: const Icon(Icons.bolt, color: themeColor),
        title: const Text('ShopVerse', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Profile Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [themeColor, Colors.orangeAccent]),
                        ),
                        child: const CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex'),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Text('GOLD', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Alex Johnson', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(Icons.stars, color: Colors.amber[700], size: 16),
                          const SizedBox(width: 4),
                          Text('Gold Member', style: TextStyle(color: Colors.amber[700], fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Verse Points Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('VERSE POINTS', style: TextStyle(color: Colors.white70, letterSpacing: 1, fontSize: 10, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('2,450 pts', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.local_offer, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress to Platinum', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('550 pts left', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildQuickAction(Icons.inventory_2_outlined, 'Orders', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
                  const SizedBox(width: 12),
                  _buildQuickAction(Icons.location_on_outlined, 'Addresses', () {}),
                  const SizedBox(width: 12),
                  _buildQuickAction(Icons.payment_outlined, 'Payments', () {}),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Redeem Rewards Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Redeem Rewards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('View All', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reward Items
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildRewardCard('\$10 Off Coupon', 'Sitewide purchase', '500 pts', Icons.confirmation_num_outlined, Colors.amber.withValues(alpha: 0.1)),
                  const SizedBox(width: 16),
                  _buildRewardCard('Free Shipping', 'On your next order', '250 pts', Icons.local_shipping_outlined, Colors.orangeAccent.withValues(alpha: 0.1)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildMenuItem(Icons.person_outline, 'Edit Profile', () {}),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.notifications_none_outlined, 'Notifications', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.help_outline, 'Help & Support', () {}),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(16)),
              child: _buildMenuItem(Icons.logout, 'Logout', () => authProvider.logout(), textColor: Colors.red),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFFF3232)),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard(String title, String subtitle, String pts, IconData icon, Color bgColor) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFFFF3232), size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF00695C), borderRadius: BorderRadius.circular(8)),
            child: Text(pts, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? textColor}) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black54),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor ?? Colors.black87)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.black26),
      onTap: onTap,
    );
  }
}
