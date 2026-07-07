import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/utils/app_colors.dart';

class PantryTrackerScreen extends StatefulWidget {
  const PantryTrackerScreen({super.key});

  @override
  State<PantryTrackerScreen> createState() => _PantryTrackerScreenState();
}

class _PantryTrackerScreenState extends State<PantryTrackerScreen> {
  bool _alertsEnabled = true;

  final List<Map<String, dynamic>> _pantryItems = [
    {
      'product': Product(
        id: 'p_milk',
        name: 'Organic Taaza Milk',
        description: 'Taaza double toned milk',
        price: 28.0,
        imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=800',
        category: 'Dairy',
      ),
      'daysTotal': 7,
      'daysLeft': 1,
    },
    {
      'product': Product(
        id: 'p_bread',
        name: 'Multigrain Brown Bread',
        description: 'Fiber-rich sliced brown bread',
        price: 45.0,
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
        category: 'Bakery',
      ),
      'daysTotal': 6,
      'daysLeft': 4,
    },
    {
      'product': Product(
        id: 'p_eggs',
        name: 'Farm Fresh White Eggs (6 pcs)',
        description: 'Protein rich clean white eggs',
        price: 52.0,
        imageUrl: 'https://images.unsplash.com/photo-1516448424440-9dbca97779c1?w=800',
        category: 'Dairy',
      ),
      'daysTotal': 14,
      'daysLeft': 12,
    }
  ];

  void _reorderItem(Product product) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reordered ${product.name}! Added to bag.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Smart Shelf Pantry', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notifications controller card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.orangeAccent),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expiry Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Get notified before items spoil', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _alertsEnabled,
                      activeThumbColor: Colors.orangeAccent,
                      onChanged: (val) {
                        setState(() {
                          _alertsEnabled = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'My Pantry Shelf Inventory',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),

              // Items loop
              ..._pantryItems.map((item) {
                final Product prod = item['product'] as Product;
                final int daysTotal = item['daysTotal'] as int;
                final int daysLeft = item['daysLeft'] as int;
                final double percentLeft = (daysLeft / daysTotal).clamp(0.0, 1.0);

                Color progressColor = Colors.green;
                String statusLabel = 'Fresh';

                if (daysLeft <= 1) {
                  progressColor = Colors.red;
                  statusLabel = 'Expires tomorrow!';
                } else if (daysLeft <= 4) {
                  progressColor = Colors.amber;
                  statusLabel = 'Expires in $daysLeft days';
                } else {
                  statusLabel = 'Fresh: $daysLeft days left';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          prod.imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statusLabel,
                              style: TextStyle(color: progressColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            // Freshness horizontal progress bar indicator
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentLeft,
                                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                valueColor: AlwaysStoppedAnimation(progressColor),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Reorder Action button
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.primary),
                        onPressed: () => _reorderItem(prod),
                        tooltip: 'Quick Reorder',
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
