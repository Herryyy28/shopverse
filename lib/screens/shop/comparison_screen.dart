import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/compare_provider.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final compareProv = Provider.of<CompareProvider>(context);
    final products = compareProv.items;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Product Comparison', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
        actions: [
          if (products.isNotEmpty)
            TextButton(
              onPressed: () => compareProv.clear(),
              child: const Text('Clear All', style: TextStyle(color: AppColors.brandRed)),
            ),
        ],
      ),
      body: products.isEmpty
          ? _buildEmptyState(context, isDark)
          : Column(
              children: [
                // Top Header Row showing images & names
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                  child: Row(
                    children: [
                      // Spec Labels Column Placeholder
                      const SizedBox(
                        width: 100,
                        child: Center(
                          child: Text(
                            'Products',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      // Product Columns
                      Expanded(
                        child: Row(
                          children: products.map((p) => _buildProductHeader(context, p, compareProv)).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Detailed Specs List
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                      child: Column(
                        children: [
                          _buildSpecRow('Price', products.map((p) => '₹${p.price.toInt()}').toList(), isDark, highlightMin: true),
                          _buildSpecRow('Brand', products.map((p) => p.brand).toList(), isDark),
                          _buildSpecRow('Rating', products.map((p) => '${p.rating} ★').toList(), isDark),
                          _buildSpecRow('Reviews', products.map((p) => '${p.reviews}').toList(), isDark),
                          _buildSpecRow('Category', products.map((p) => p.category).toList(), isDark),
                          // Collect all spec keys from compared items
                          ..._gatherAllSpecKeys(products).map((key) {
                            return _buildSpecRow(
                              key,
                              products.map((p) => p.specifications[key] ?? '-').toList(),
                              isDark,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare, size: 80, color: isDark ? Colors.white24 : Colors.grey[300]),
            const SizedBox(height: 24),
            const Text(
              'No products selected',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add up to 3 products from their details pages to compare specs side-by-side.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: CustomButton(
                text: 'GO BACK',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, Product p, CompareProvider compareProv) {
    return Expanded(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: p.imageUrl,
                  height: 70,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(p);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to Bag'), backgroundColor: Colors.green),
                      );
                    },
                    child: const Text('ADD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          // Delete button
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => compareProv.removeProduct(p.id),
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.close, size: 10, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, List<String> values, bool isDark, {bool highlightMin = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.grey[850]! : Colors.grey[100]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row Label
          Container(
            width: 100,
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF131320) : Colors.grey[50],
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          // Row Values
          Expanded(
            child: Row(
              children: values.map((val) {
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Text(
                      val,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _gatherAllSpecKeys(List<Product> products) {
    final Set<String> keys = {};
    for (var p in products) {
      keys.addAll(p.specifications.keys);
    }
    return keys.toList();
  }
}
