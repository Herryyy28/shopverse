import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/product_provider.dart';
import 'package:shopverse/providers/order_provider.dart';
import 'package:shopverse/providers/user_provider.dart';
import 'package:shopverse/providers/notification_provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/models/order_item.dart';
import 'package:shopverse/services/firebase_service.dart';
import 'package:shopverse/screens/admin/admin_orders_screen.dart';
import 'package:shopverse/screens/admin/add_product_screen.dart';
import 'package:shopverse/screens/admin/manage_products_screen.dart';
import 'package:shopverse/screens/shop/categories_screen.dart';
import 'package:shopverse/screens/profile/notifications_screen.dart';
import 'package:shopverse/screens/admin/admin_chat_list_screen.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';
import 'package:shopverse/widgets/custom_text_field.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Store Management', 
                style: TextStyle(
                  color: AppColors.textPrimary, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 18,
                  letterSpacing: -0.5,
                )
              ),
              background: Container(color: AppColors.surfaceColor),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              ),
            ],
            backgroundColor: AppColors.surfaceColor,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Product>>(
              stream: productProv.productsStream,
              builder: (context, productSnapshot) {
                return StreamBuilder<List<OrderItem>>(
                  stream: orderProv.ordersStream,
                  builder: (context, orderSnapshot) {
                    final products = productSnapshot.data ?? productProv.products;
                    final orders = orderSnapshot.data ?? orderProv.orders;
                    final totalRevenue = orders.fold(0.0, (sum, order) => sum + order.amount);

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutQuart,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildSummaryGrid(totalRevenue, orders.length, products.length),
                          ),
                          const SizedBox(height: 24),
                          const Text('Inventory Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _QuickAction(label: 'Add Item', icon: Icons.add_photo_alternate, color: AppColors.brandRed, onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                              }, index: 0),
                              const SizedBox(width: 12),
                              _QuickAction(label: 'Manage', icon: Icons.inventory, color: Colors.blue, onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageProductsScreen()));
                              }, index: 1),
                              const SizedBox(width: 12),
                              _QuickAction(label: 'Orders', icon: Icons.local_shipping, color: Colors.orange, onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen()));
                              }, index: 2),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Text('Store Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 16),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutQuart,
                            builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child)),
                            child: _buildPerformanceCard(),
                          ),
                          const SizedBox(height: 32),
                          _ActionTile(icon: Icons.category_outlined, title: 'Categories', subtitle: 'Organize your products', index: 0, onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                          }),
                          _ActionTile(icon: Icons.campaign_outlined, title: 'Marketing', subtitle: 'Send push notifications', index: 1, onTap: () {
                             _sendNotificationDialog(context);
                          }),
                          _ActionTile(icon: Icons.people_outline, title: 'Customers', subtitle: 'View user base', index: 2, onTap: () {
                             _showUserManagement(context);
                          }),
                          _ActionTile(icon: Icons.chat_bubble_outline, title: 'Support', subtitle: 'Real-time customer Q&A', index: 3, onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
                          }),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(double revenue, int orders, int products) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.brandRed,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandRed.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL REVENUE',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: revenue),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeOutQuart,
                    builder: (context, value, child) {
                      return Text('₹${value.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1));
                    },
                  ),
                ],
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.trending_up, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallStat('Orders', '$orders'),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildSmallStat('Items', '$products'),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildSmallStat('Growth', '+12%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Fulfilment', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Average time: 12 mins', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Text('98%', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w900, fontSize: 20)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.98),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOutQuart,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey[100],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 10,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUserManagement(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.symmetric(vertical: 16), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Text('User Base', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: userProv.users.length,
                padding: const EdgeInsets.all(20),
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (ctx, i) {
                  final user = userProv.users[i];
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(user.profileImageUrl ?? 'https://ui-avatars.com/api/?name=${user.name}'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.role == 'admin' ? Colors.amber[100] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.role.toUpperCase(), 
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.w900,
                            color: user.role == 'admin' ? Colors.amber[900] : Colors.blue[900],
                          )
                        ),
                      ),
                    ],
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
    final titleController = TextEditingController(text: 'Flash Sale! ⚡');
    final bodyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Broadcast Message', style: TextStyle(fontWeight: FontWeight.w900)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: titleController,
              label: 'Title',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: bodyController,
              label: 'Message body...',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary))),
          SizedBox(
            width: 120,
            child: CustomButton(
              text: 'SEND',
              onPressed: () async {
                if (bodyController.text.isNotEmpty) {
                  await FirebaseService.sendBroadcastNotification(titleController.text, bodyController.text);
                  
                  if (ctx.mounted) {
                    Provider.of<NotificationProvider>(context, listen: false).addNotification(
                      titleController.text,
                      bodyController.text,
                    );
                    Navigator.pop(ctx);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to all users!')));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int index;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.index,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600 + (widget.index * 100)),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: widget.color.withValues(alpha: 0.1),
                    child: Icon(widget.icon, color: widget.color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.label,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int index;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.index,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (widget.index * 150)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(40 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.backgroundColor, borderRadius: BorderRadius.circular(16)),
                child: Icon(widget.icon, color: AppColors.textPrimary, size: 24),
              ),
              title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              subtitle: Text(widget.subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}
