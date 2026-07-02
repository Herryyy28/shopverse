import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class RecipeBuilderScreen extends StatelessWidget {
  const RecipeBuilderScreen({super.key});

  static final List<Map<String, dynamic>> _recipes = [
    {
      'id': 'r1',
      'title': 'Rich Chocolate Lava Cake',
      'image': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=600',
      'description': 'Warm chocolate cake with a molten lava core. Quick and delicious dessert recipe.',
      'time': '20 mins',
      'ingredients': [
        Product(
          id: 'p3',
          name: 'Aashirvaad Superior MP Atta',
          description: 'Whole wheat flour for cake structure',
          price: 245.0,
          imageUrl: 'https://m.media-amazon.com/images/I/81RAtC9zU2L._SL1500_.jpg',
          category: 'Grocery',
        ),
        Product(
          id: 'p1',
          name: 'Amul Taaza Milk',
          description: 'Fresh milk for smooth batter mixing',
          price: 27.0,
          imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=800',
          category: 'Dairy',
          unit: '500 ml',
        )
      ]
    },
    {
      'id': 'r2',
      'title': 'Healthy Breakfast Oatmeal Pancake',
      'image': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=600',
      'description': 'Nutritious pancakes topped with honey and fresh cream.',
      'time': '15 mins',
      'ingredients': [
        Product(
          id: 'p2',
          name: 'Fortune Sunlite Sunflower Oil',
          description: 'Light oil for shallow pan frying',
          price: 145.0,
          imageUrl: 'https://m.media-amazon.com/images/I/71p0WfB6LHL._SL1500_.jpg',
          category: 'Grocery',
        ),
        Product(
          id: 'p1',
          name: 'Amul Taaza Milk',
          description: 'Fresh toned milk',
          price: 27.0,
          imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=800',
          category: 'Dairy',
          unit: '500 ml',
        )
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Recipe-to-Cart', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          final List<Product> items = List<Product>.from(recipe['ingredients']);
          double totalCost = 0;
          for (var p in items) {
            totalCost += p.price;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Header Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: CachedNetworkImage(
                    imageUrl: recipe['image'] as String,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              recipe['title'] as String,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ),
                          Chip(
                            label: Text(
                              recipe['time'] as String,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: AppColors.primaryLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recipe['description'] as String,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Required Ingredients',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      
                      // Ingredients Sub-items
                      ...items.map((prod) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  prod.name,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Text(
                                '₹${prod.price.toInt()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Order ingredients package
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Package Cost', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                Text(
                                  '₹${totalCost.toInt()}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: CustomButton(
                              text: 'ADD INGREDIENTS',
                              onPressed: () {
                                final cart = Provider.of<CartProvider>(context, listen: false);
                                for (var p in items) {
                                  cart.addItem(p);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('All ingredients for ${recipe['title']} added to bag!'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
