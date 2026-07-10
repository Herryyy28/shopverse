import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/order_provider.dart';
import 'package:intl/intl.dart';
import 'package:shopverse/screens/checkout/tracking_screen.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/utils/app_spacing.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final orders = orderProv.orders;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.backgroundColor,
      appBar: AppBar(title: const Text('My Orders'), centerTitle: false),
      body: orders.isEmpty
          ? _buildEmptyState(isDark)
          : _buildOrdersList(context, orders, isDark),
    );
  }

  Widget _buildOrdersList(BuildContext context, List orders, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        final isLive =
            index == 0 &&
            DateTime.now().difference(order.createdAt).inMinutes < 15;
        return _OrderCard(order: order, isLive: isLive, isDark: isDark);
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface2 : AppColors.surface2,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 52,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No orders yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your order history will appear here',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order;
  final bool isLive, isDark;
  const _OrderCard({
    required this.order,
    required this.isLive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isLive ? AppColors.success : AppColors.textMuted;
    final statusBg = isLive
        ? AppColors.successLight
        : (isDark ? AppColors.darkSurface2 : AppColors.surface2);
    final statusLabel = isLive
        ? '🟢 Live'
        : order.status.toString().split('.').last.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadow.sm,
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(order.createdAt),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ORD-${order.id.substring(order.id.length - 6).toUpperCase()}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),

          // ── Timeline Progress ─────────────────────────────────────────
          if (isLive) _buildDeliveryTimeline(isDark),

          // ── Items + Actions ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : AppColors.surface2,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.items.length} ${order.items.length == 1 ? "item" : "items"}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLive)
                  _ActionButton(
                    label: 'Track',
                    icon: Icons.location_on_rounded,
                    color: AppColors.success,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackingScreen(orderId: order.id),
                      ),
                    ),
                  )
                else
                  _ActionButton(
                    label: 'Reorder',
                    icon: Icons.replay_rounded,
                    color: AppColors.primary,
                    onTap: () {
                      final cartProv = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );
                      int added = 0;
                      for (var item in order.items) {
                        try {
                          cartProv.addItem(item.product);
                          added++;
                        } catch (_) {}
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(added > 0 ? '$added items added to cart! 🛍️' : 'Cannot reorder legacy items.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: added > 0
                              ? AppColors.success
                              : AppColors.brandRed,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeline(bool isDark) {
    final steps = [
      {'label': 'Ordered', 'icon': Icons.check_circle_rounded, 'done': true},
      {'label': 'Packed', 'icon': Icons.inventory_2_rounded, 'done': true},
      {
        'label': 'On the way',
        'icon': Icons.delivery_dining_rounded,
        'done': false,
      },
      {'label': 'Delivered', 'icon': Icons.home_rounded, 'done': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final step = e.value;
          final isLast = e.key == steps.length - 1;
          final done = step['done'] as bool;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.success
                            : (isDark
                                  ? AppColors.darkSurface2
                                  : AppColors.surface2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        size: 16,
                        color: done ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['label'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                        color: done ? AppColors.success : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      color: done
                          ? AppColors.success
                          : (isDark ? AppColors.borderDark : AppColors.border),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
