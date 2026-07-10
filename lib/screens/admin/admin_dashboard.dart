import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/product_provider.dart';
import 'package:shopverse/providers/order_provider.dart';
import 'package:shopverse/providers/user_provider.dart';
import 'package:shopverse/providers/notification_provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/models/order_model.dart';
import 'package:shopverse/services/firebase_service.dart';
import 'package:shopverse/screens/admin/admin_orders_screen.dart';
import 'package:shopverse/screens/admin/add_product_screen.dart';
import 'package:shopverse/screens/admin/manage_products_screen.dart';
import 'package:shopverse/screens/shop/categories_screen.dart';
import 'package:shopverse/screens/profile/notifications_screen.dart';
import 'package:shopverse/screens/admin/admin_chat_list_screen.dart';
import 'package:shopverse/providers/auth_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';
import 'package:shopverse/widgets/custom_text_field.dart';

class AdminDashboard extends StatelessWidget {
  final String? vendorId; // If null, super-admin. If provided, vendor.
  const AdminDashboard({super.key, this.vendorId});

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final user = authProv.user;
    
    // Guard: Block access if user is not authenticated or lacks correct permissions
    if (user == null || (user.role != 'admin' && user.role != 'vendor' && user.role != 'seller')) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gpp_bad_outlined, size: 80, color: AppColors.brandRed),
                SizedBox(height: 16),
                Text("Access Denied", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("You do not have administrative permissions to access this screen.", 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      );
    }

    final productProv = Provider.of<ProductProvider>(context);

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
                return StreamBuilder<List<OrderModel>>(
      stream: Provider.of<OrderProvider>(context).ordersStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final bool isVendor = vendorId != null;
        final orders = snapshot.data ?? [];
        var scopedOrders = orders;
        var scopedProducts = productSnapshot.data ?? productProv.products;
        
        if (isVendor) {
          scopedOrders = orders.where((o) => o.items.any((i) => i.product.vendorId == vendorId)).toList();
          scopedProducts = scopedProducts.where((p) => p.vendorId == vendorId).toList();
        }
        
        final todayOrders = scopedOrders.where((o) => 
          o.createdAt.year == DateTime.now().year &&
          o.createdAt.month == DateTime.now().month &&
          o.createdAt.day == DateTime.now().day
        ).toList();
        
        final revenue = todayOrders.fold(0.0, (sum, order) {
          if (!isVendor) return sum + order.totalAmount;
          final vendorItems = order.items.where((i) => i.product.vendorId == vendorId);
          final vendorSum = vendorItems.fold(0.0, (s, i) => s + (i.product.price * i.quantity));
          return sum + vendorSum;
        });

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
                            child: _buildSummaryGrid(revenue, scopedOrders.length, scopedProducts.length),
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
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ManageProductsScreen(vendorId: vendorId)));
                              }, index: 1),
                              const SizedBox(width: 12),
                              _QuickAction(label: 'Orders', icon: Icons.local_shipping, color: Colors.orange, onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminOrdersScreen(vendorId: vendorId)));
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
                           if (!isVendor) ...[
                            _ActionTile(icon: Icons.category_outlined, title: 'Categories', subtitle: 'Organize your products', index: 0, onTap: () {
                               Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                            }),
                            _ActionTile(icon: Icons.campaign_outlined, title: 'Marketing', subtitle: 'Send push notifications', index: 1, onTap: () {
                               _sendNotificationDialog(context);
                            }),
                            _ActionTile(icon: Icons.people_outline, title: 'Customers', subtitle: 'View user base', index: 2, onTap: () {
                               _showUserManagement(context);
                            }),
                             _ActionTile(icon: Icons.cloud_upload_outlined, title: 'Seed Products Data', subtitle: 'Upload sample products to Firestore', index: 3, onTap: () async {
                               showDialog(
                                 context: context,
                                 barrierDismissible: false,
                                 builder: (ctx) => const Center(child: CircularProgressIndicator()),
                               );
                               try {
                                 await productProv.seedMockData();
                                 if (context.mounted) {
                                   Navigator.pop(context);
                                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Firestore database seeded successfully!')));
                                 }
                               } catch (e) {
                                 if (context.mounted) {
                                   Navigator.pop(context);
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seeding failed: $e')));
                                 }
                               }
                            }),
                            _ActionTile(icon: Icons.local_shipping_outlined, title: 'Delivery Partners', subtitle: 'Manage riders and assign orders', index: 4, onTap: () {
                               _showDeliveryPartnerManagement(context);
                            }),
                            _ActionTile(icon: Icons.bar_chart_outlined, title: 'Sales Reports', subtitle: 'Detailed revenue & order trends', index: 5, onTap: () {
                               _showSalesReport(context);
                            }),
                          ],
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
                separatorBuilder: (_, _) => const Divider(height: 24),
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

  void _showDeliveryPartnerManagement(BuildContext context) {
    final partners = [
      {'name': 'Rahul Sharma', 'status': 'Active', 'deliveries': 14, 'phone': '+91 98765 43210'},
      {'name': 'Vikram Singh', 'status': 'On Delivery', 'deliveries': 9, 'phone': '+91 99887 76655'},
      {'name': 'Amit Kumar', 'status': 'Active', 'deliveries': 18, 'phone': '+91 91234 56789'},
      {'name': 'Priya Patel', 'status': 'Offline', 'deliveries': 0, 'phone': '+91 88776 65544'},
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Delivery Partners', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            const Divider(height: 1),
            Expanded(
               child: ListView.separated(
                 itemCount: partners.length,
                 padding: const EdgeInsets.all(20),
                 separatorBuilder: (_, _) => const Divider(height: 24),
                 itemBuilder: (ctx, i) {
                   final partner = partners[i];
                   final isActive = partner['status'] == 'Active';
                   final isOnTrip = partner['status'] == 'On Delivery';
                   
                   return Row(
                     children: [
                       CircleAvatar(
                         radius: 24,
                         backgroundColor: Colors.grey[100],
                         child: const Icon(Icons.directions_bike, color: AppColors.textPrimary),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(partner['name'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                             const SizedBox(height: 2),
                             Text('${partner['phone']} • ${partner['deliveries']} trips today', 
                               style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                           ],
                         ),
                       ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(
                           color: isActive ? Colors.green[50] : (isOnTrip ? Colors.blue[50] : Colors.grey[100]),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Text(
                           (partner['status'] as String).toUpperCase(),
                           style: TextStyle(
                             fontSize: 10,
                             fontWeight: FontWeight.w900,
                             color: isActive ? Colors.green[700] : (isOnTrip ? Colors.blue[700] : Colors.grey[600]),
                           ),
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

   void _showSalesReport(BuildContext context) {
     showModalBottomSheet(
       context: context,
       isScrollControlled: true,
       backgroundColor: Colors.transparent,
       builder: (context) => Container(
         height: MediaQuery.of(context).size.height * 0.8,
         decoration: const BoxDecoration(
           color: AppColors.surfaceColor,
           borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
         ),
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 24),
           child: Column(
             children: [
               Container(
                 margin: const EdgeInsets.symmetric(vertical: 16),
                 width: 40,
                 height: 4,
                 decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
               ),
               const Text('Sales & Revenue Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
               const SizedBox(height: 24),
               
               Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   color: AppColors.backgroundColor,
                   borderRadius: BorderRadius.circular(24),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text('WEEKLY PERFORMANCE', 
                       style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                     const SizedBox(height: 20),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                         _buildBar('Mon', 45),
                         _buildBar('Tue', 65),
                         _buildBar('Wed', 80),
                         _buildBar('Thu', 50),
                         _buildBar('Fri', 95),
                         _buildBar('Sat', 120),
                         _buildBar('Sun', 110),
                       ],
                     ),
                   ],
                 ),
               ),
               const SizedBox(height: 24),
               
               Row(
                 children: [
                   Expanded(
                     child: _buildReportCard('Average Order', '₹345', Icons.shopping_bag_outlined, Colors.purple),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: _buildReportCard('Refund Rate', '1.2%', Icons.assignment_return_outlined, Colors.red),
                   ),
                 ],
               ),
               const SizedBox(height: 24),
               
               SizedBox(
                 width: double.infinity,
                 height: 52,
                 child: CustomButton(
                   text: 'EXPORT PDF REPORT',
                   onPressed: () {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Sales report exported to Documents!'), behavior: SnackBarBehavior.floating),
                     );
                   },
                 ),
               ),
               const SizedBox(height: 24),
             ],
           ),
         ),
       ),
     );
   }

   Widget _buildBar(String label, double heightVal) {
     return Column(
       children: [
         Container(
           width: 18,
           height: heightVal,
           decoration: BoxDecoration(
             gradient: AppColors.primaryGradient,
             borderRadius: BorderRadius.circular(6),
           ),
         ),
         const SizedBox(height: 8),
         Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
       ],
     );
   }

   Widget _buildReportCard(String title, String val, IconData icon, Color color) {
     return Container(
       padding: const EdgeInsets.all(18),
       decoration: BoxDecoration(
         color: AppColors.backgroundColor,
         borderRadius: BorderRadius.circular(20),
         border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
       ),
       child: Row(
         children: [
           CircleAvatar(
             radius: 18,
             backgroundColor: color.withValues(alpha: 0.1),
             child: Icon(icon, color: color, size: 18),
           ),
           const SizedBox(width: 12),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
               const SizedBox(height: 2),
               Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
             ],
           ),
         ],
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
                    Navigator.pop(ctx);
                  }
                  if (context.mounted) {
                    Provider.of<NotificationProvider>(context, listen: false).addNotification(
                      titleController.text,
                      bodyController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to all users!')));
                  }
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
            opacity: value.clamp(0.0, 1.0),
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
