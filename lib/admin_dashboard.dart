import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/product_provider.dart';
import 'package:shopverse/providers/order_provider.dart';
import 'package:shopverse/providers/user_provider.dart';
import 'package:shopverse/providers/notification_provider.dart';
import 'package:shopverse/services/firebase_service.dart';
import 'package:shopverse/add_product_screen.dart';
import 'package:shopverse/manage_products_screen.dart';
import 'package:shopverse/admin_orders_screen.dart';
import 'package:shopverse/categories_screen.dart';
import 'package:shopverse/notifications_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandRed = Color(0xFFFF3232);
    
    // Connect to real data providers for dynamic stats
    final productProv = Provider.of<ProductProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);
    final userProv = Provider.of<UserProvider>(context);
    
    return StreamBuilder<List<OrderItem>>(
      stream: orderProv.ordersStream,
      builder: (context, orderSnapshot) {
        return StreamBuilder<List<Product>>(
          stream: productProv.productsStream,
          builder: (context, productSnapshot) {
            return StreamBuilder<List<UserModel>>(
              stream: userProv.usersStream,
              builder: (context, userSnapshot) {
                final orders = orderSnapshot.data ?? orderProv.orders;
                final products = productSnapshot.data ?? productProv.products;
                final users = userSnapshot.data ?? userProv.users;

                final totalProducts = products.length;
                final totalOrders = orders.length;
                final totalRevenue = orders.fold(0.0, (sum, order) => sum + order.amount);
                final totalUsers = users.length;

                return Scaffold(
                  backgroundColor: const Color(0xFFF5F5F5),
                  appBar: AppBar(
                    title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Overview',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.4,
                          children: [
                            _buildStatCard('Revenue', '₹${totalRevenue.toStringAsFixed(2)}', Icons.payments, Colors.green),
                            _buildStatCard('Total Orders', '$totalOrders', Icons.shopping_bag, Colors.blue),
                            _buildStatCard('Users', '$totalUsers', Icons.people, Colors.orange),
                            _buildStatCard('Products', '$totalProducts', Icons.inventory_2, Colors.purple),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Quick Management',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildActionTile(Icons.inventory_2_outlined, 'Manage Products', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageProductsScreen()));
                        }),
                        _buildActionTile(Icons.add_box_outlined, 'Add New Product', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                        }),
                        _buildActionTile(Icons.category_outlined, 'Manage Categories', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                        }),
                        _buildActionTile(Icons.local_shipping_outlined, 'Manage Orders', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen()));
                        }),
                        _buildActionTile(Icons.people_outline, 'User Management', () {
                          _showUserManagement(context);
                        }),
                        _buildActionTile(Icons.campaign_outlined, 'Push Notification Center', () {
                           _sendNotificationDialog(context);
                        }),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showUserManagement(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Text('User Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: userProv.users.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (ctx, i) {
                  final user = userProv.users[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFFEAEA),
                      backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
                      child: user.profileImageUrl == null ? const Icon(Icons.person, color: Color(0xFFFF3232)) : null,
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        color: user.role == 'admin' ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendNotificationDialog(BuildContext context) {
    final titleController = TextEditingController(text: 'New Update!');
    final bodyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Broadcast'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This message will be sent to all active app users.'),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Notification Title',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type message body...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              if (bodyController.text.isNotEmpty) {
                final nav = Navigator.of(ctx);
                final scaffold = ScaffoldMessenger.of(context);
                final notifProv = Provider.of<NotificationProvider>(context, listen: false);
                
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                await FirebaseService.sendBroadcastNotification(
                  titleController.text,
                  bodyController.text,
                );

                // Add to local history
                notifProv.addNotification(titleController.text, bodyController.text);

                if (ctx.mounted) Navigator.pop(ctx); // Close loading
                nav.pop(); // Close dialog
                
                scaffold.showSnackBar(
                  const SnackBar(content: Text('Notification broadcasted successfully!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('SEND NOW'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF3232)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
