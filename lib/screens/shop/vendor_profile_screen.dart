import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/models/user_model.dart';
import 'package:shopverse/providers/product_provider.dart';
import 'package:shopverse/providers/user_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/product_card.dart';

class VendorProfileScreen extends StatelessWidget {
  final String vendorId;
  
  const VendorProfileScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final productProv = Provider.of<ProductProvider>(context);
    
    // Find vendor user model (if it exists)
    final UserModel? vendor = userProv.users.cast<UserModel?>().firstWhere(
      (u) => u?.uid == vendorId, 
      orElse: () => null,
    );
    
    final List<Product> vendorProducts = productProv.getProductsByVendor(vendorId);
    
    final String storeName = vendor?.storeName ?? vendorProducts.firstOrNull?.vendorName ?? 'Store';
    final String bannerUrl = vendor?.storeBannerUrl ?? 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.brandRed,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                storeName,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 10)]),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(bannerUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      storeName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.brandRed),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(storeName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const Text(' 4.8 (1.2k Ratings)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(width: 12),
                            Icon(Icons.verified, color: Colors.blue[400], size: 16),
                            const Text(' Verified Seller', style: TextStyle(color: Colors.blue, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('All Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),
          ),
          if (vendorProducts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No products found for this seller.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(product: vendorProducts[index]),
                  childCount: vendorProducts.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
