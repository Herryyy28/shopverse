import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class GroupRegistryScreen extends StatefulWidget {
  const GroupRegistryScreen({super.key});

  @override
  State<GroupRegistryScreen> createState() => _GroupRegistryScreenState();
}

class _GroupRegistryScreenState extends State<GroupRegistryScreen> {
  final List<Map<String, dynamic>> _registryItems = [
    {
      'product': Product(
        id: 'p0',
        name: 'Aura Pro Wireless Headphones - Midnight Purple',
        brand: 'AURA',
        description: 'Noise cancelling headphones',
        price: 299.0,
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
        category: 'Electronics',
      ),
      'claimed': true,
      'claimedBy': 'Rahul Kumar',
    },
    {
      'product': Product(
        id: 'p00',
        name: 'Chronos Classic Steel Edition',
        brand: 'CHRONOS',
        description: 'Sapphire glass steel edition watch',
        price: 185.0,
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        category: 'Accessories',
      ),
      'claimed': false,
      'claimedBy': '',
    }
  ];

  void _claimItem(int index) {
    setState(() {
      _registryItems[index]['claimed'] = true;
      _registryItems[index]['claimedBy'] = 'You';
    });

    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(_registryItems[index]['product'] as Product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${_registryItems[index]['product'].name} to cart for the registry!'),
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
        title: const Text('Gift Registry Catalog', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.cake, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'CELEBRATIONS REGISTRY',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Herry\'s Birthday Wishlist',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select an item from the list below to purchase and deliver directly to Herry!',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Wishlist Registry Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),

              // Items Loop
              ..._registryItems.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final Product prod = data['product'] as Product;
                final bool claimed = data['claimed'] as bool;
                final String claimedBy = data['claimedBy'] as String;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: claimed ? Colors.green.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          prod.imageUrl,
                          width: 60,
                          height: 60,
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
                              '₹${prod.price.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
                            ),
                            if (claimed) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Claimed by $claimedBy',
                                    style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),

                      // Buy action button
                      if (!claimed)
                        ElevatedButton(
                          onPressed: () => _claimItem(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('GIFT THIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
