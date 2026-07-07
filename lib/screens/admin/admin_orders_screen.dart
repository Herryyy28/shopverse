import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/order_provider.dart';
import 'package:shopverse/models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:shopverse/utils/app_colors.dart';

class AdminOrdersScreen extends StatefulWidget {
  final String? vendorId; // If null, super-admin. If provided, vendor.
  const AdminOrdersScreen({super.key, this.vendorId});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _filterStatus = 'All';

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    
    return StreamBuilder<List<OrderModel>>(
      stream: orderProv.ordersStream,
      builder: (context, snapshot) {
        var allOrders = snapshot.data ?? orderProv.orders;
        
        // Scope orders to vendor if applicable
        if (widget.vendorId != null) {
          allOrders = allOrders.where((o) => o.items.any((i) => i.product.vendorId == widget.vendorId)).toList();
        }
        
        var orders = List<OrderModel>.from(allOrders);
        
        // Calculate Statistics for Dashboard
        final totalRevenue = allOrders.fold(0.0, (sum, item) {
          if (widget.vendorId == null) return sum + item.totalAmount;
          final vendorItems = item.items.where((i) => i.product.vendorId == widget.vendorId);
          return sum + vendorItems.fold(0.0, (s, i) => s + (i.product.price * i.quantity));
        });
        
        final pendingOrdersCount = allOrders.where((o) => o.status.toString().split('.').last.toUpperCase() == 'PENDING').length;

        // Apply Filter
        if (_filterStatus != 'All') {
          orders = orders.where((o) => o.status.toString().split('.').last.toUpperCase() == _filterStatus.toUpperCase()).toList();
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text('Admin Dashboard', 
                style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.brandRed, fontSize: 22)),
              bottom: const TabBar(
                labelColor: AppColors.brandRed,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.brandRed,
                tabs: [
                  Tab(text: 'ORDERS'),
                  Tab(text: 'ANALYTICS'),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () => orderProv.fetchOrders(), 
                  icon: const Icon(Icons.refresh, color: AppColors.brandRed)
                ),
              ],
            ),
            body: TabBarView(
              children: [
                // Orders Tab
                _buildOrdersTab(orders, totalRevenue, pendingOrdersCount, allOrders, snapshot, orderProv),
                
                // Analytics Tab
                _buildAnalyticsTab(allOrders, totalRevenue),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab(List<OrderModel> orders, double totalRevenue, int pendingOrdersCount, List<OrderModel> allOrders, AsyncSnapshot snapshot, OrderProvider orderProv) {
    return Column(
      children: [
        // Dashboard Summary Stats
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              _buildStatCard('Total Orders', allOrders.length.toString(), Icons.shopping_bag_outlined, Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('Revenue', '₹${totalRevenue.toStringAsFixed(0)}', Icons.payments_outlined, Colors.green),
              const SizedBox(width: 12),
              _buildStatCard('Pending', pendingOrdersCount.toString(), Icons.timer_outlined, Colors.orange),
            ],
          ),
        ),
        
        // Filter Chips
        Container(
          height: 50,
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].map((status) {
              final isSelected = _filterStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _filterStatus = status);
                  },
                  selectedColor: _getStatusColor(status).withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? _getStatusColor(status) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: orders.isEmpty
                ? Center(
                    key: ValueKey('empty_$_filterStatus'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No $_filterStatus orders found', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    key: ValueKey('list_$_filterStatus'),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final statusString = order.status.toString().split('.').last.toUpperCase();
                      final statusColor = _getStatusColor(statusString);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.receipt_long, color: statusColor, size: 24),
                            ),
                            title: Row(
                              children: [
                                Text('#${order.id.length > 5 ? order.id.substring(order.id.length - 5).toUpperCase() : order.id}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const Spacer(),
                                Text('₹${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.brandRed)),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Text(DateFormat('dd MMM, hh:mm a').format(order.createdAt), 
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(statusString, 
                                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(height: 1),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Text('User ID: ${order.userId}', 
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 8),
                                    ...order.items.map((p) {
                                      final isMyItem = widget.vendorId == null || p.product.vendorId == widget.vendorId;
                                      
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 4, height: 4,
                                              decoration: BoxDecoration(color: isMyItem ? AppColors.brandRed : Colors.grey, shape: BoxShape.circle),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                p.product.name, 
                                                style: TextStyle(
                                                  fontSize: 14, 
                                                  color: isMyItem ? AppColors.textPrimary : Colors.grey,
                                                  fontWeight: isMyItem ? FontWeight.bold : FontWeight.normal,
                                                )
                                              )
                                            ),
                                            Text('x${p.quantity}', style: TextStyle(fontWeight: FontWeight.bold, color: isMyItem ? AppColors.textPrimary : Colors.grey)),
                                            const SizedBox(width: 12),
                                            Text('₹${(p.product.price * p.quantity).toStringAsFixed(0)}', style: TextStyle(fontSize: 14, color: isMyItem ? AppColors.textPrimary : Colors.grey)),
                                          ],
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 16),
                                    const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 12),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].map((status) {
                                          final isSelected = statusString == status.toUpperCase();
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: ChoiceChip(
                                              label: Text(status),
                                              selected: isSelected,
                                              selectedColor: _getStatusColor(status),
                                              labelStyle: TextStyle(
                                                color: isSelected ? Colors.white : Colors.black87,
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                              onSelected: (selected) {
                                                if (selected) {
                                                  // Map string to OrderStatus enum
                                                  final enumValue = OrderStatus.values.firstWhere(
                                                    (e) => e.toString().split('.').last.toUpperCase() == status.toUpperCase(),
                                                    orElse: () => OrderStatus.pending,
                                                  );
                                                  orderProv.updateOrderStatus(order.id, enumValue);
                                                }
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(List<OrderModel> orders, double totalRevenue) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: CustomPaint(
              painter: RevenueChartPainter(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Activity Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          ...List.generate(5, (index) => _buildActivityItem(index)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      {'title': 'Status Updated', 'desc': 'Order #A45B1 marked as Shipped', 'time': '2 mins ago', 'icon': Icons.local_shipping},
      {'title': 'New Order', 'desc': 'Fresh order received from User #902', 'time': '15 mins ago', 'icon': Icons.shopping_cart},
      {'title': 'Refund Processed', 'desc': 'Refund for #C0921 initiated', 'time': '1 hour ago', 'icon': Icons.currency_exchange},
      {'title': 'Inventory Alert', 'desc': 'Product "Maggi Noodles" low on stock', 'time': '3 hours ago', 'icon': Icons.warning_amber},
      {'title': 'System Sync', 'desc': 'Firebase database sync successful', 'time': '5 hours ago', 'icon': Icons.sync},
    ];
    
    final activity = activities[index % activities.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.brandRed.withValues(alpha: 0.1),
            child: Icon(activity['icon'] as IconData, color: AppColors.brandRed, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(activity['desc'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(activity['time'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            FittedBox(
              child: Text(value, 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 4),
            Text(title, 
              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandRed
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.9, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.2);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.brandRed.withValues(alpha: 0.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw grid lines
    final gridPaint = Paint()..color = Colors.black.withValues(alpha: 0.05)..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
