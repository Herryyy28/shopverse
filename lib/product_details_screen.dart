import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/product.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0C121D);
    const cardColor = Color(0xFF161D29);
    const accentGreen = Color(0xFF00E676);
    const accentPurple = Color(0xFFD1C4E9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ShopVerse',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.mic, color: Colors.white70), onPressed: () {}),
          Consumer<WishlistProvider>(
            builder: (context, wishlist, _) => IconButton(
              icon: Icon(
                wishlist.isFavorite(product.id) ? Icons.favorite : Icons.favorite_border,
                color: wishlist.isFavorite(product.id) ? Colors.red : Colors.white70,
              ),
              onPressed: () => wishlist.toggleWishlist(product),
            ),
          ),
          IconButton(icon: const Icon(Icons.share, color: Colors.white70), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [bgColor, Color(0xFF1A237E)],
                    ),
                  ),
                  child: Hero(
                    tag: 'product-${product.id}',
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (c, u) => const Center(child: CircularProgressIndicator(color: accentGreen)),
                      errorWidget: (c, u, e) => const Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.white24),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentGreen.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: accentGreen, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'LIMITED EDITION',
                          style: TextStyle(color: accentGreen.withValues(alpha: 0.9), fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: Colors.white),
                      SizedBox(width: 8),
                      CircleAvatar(radius: 4, backgroundColor: Colors.white24),
                      SizedBox(width: 8),
                      CircleAvatar(radius: 4, backgroundColor: Colors.white24),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: const TextStyle(color: Colors.white54, letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: accentGreen, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating} • ${product.reviews} reviews',
                              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Read All',
                        style: TextStyle(color: Colors.white38, fontSize: 12, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₹${product.price.toInt()}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 12),
                      if (product.oldPrice > product.price)
                        Text(
                          '₹${product.oldPrice.toInt()}',
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 18,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (product.discount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.discount}% OFF',
                            style: const TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: accentGreen,
                          radius: 14,
                          child: Icon(Icons.bolt, color: bgColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FLASH DELIVERY',
                                style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                  children: [
                                    TextSpan(text: 'Delivering to '),
                                    TextSpan(text: 'Home ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                    TextSpan(text: 'in '),
                                    TextSpan(text: '15 mins', style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCouponCard('SVFIRST30', 'Get 30% off on your first order', 'APPLY'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCashbackCard('Earn ₹10 Cashback'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Text('Product Story', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: const TextStyle(color: Colors.white54, height: 1.6, fontSize: 14),
                  ),

                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white12,
                          child: Text(product.brand[0], style: const TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${product.brand} Official Store', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const Row(
                                children: [
                                  Text('Verified Merchant', style: TextStyle(color: accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  CircleAvatar(radius: 2, backgroundColor: Colors.white24),
                                  SizedBox(width: 8),
                                  Text('98% Positive', style: TextStyle(color: Colors.white38, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('FOLLOW', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildReferralSection(accentPurple, bgColor),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: bgColor,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              _buildAddCartButton(product, context),
              const SizedBox(width: 16),
              _buildBuyNowButton(accentPurple, bgColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponCard(String code, String desc, String action) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161D29),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_num_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          Align(
            alignment: Alignment.centerRight,
            child: Text(action, style: const TextStyle(color: Color(0xFF9FA8DA), fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildCashbackCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161D29),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF00E676), size: 14),
              const SizedBox(width: 4),
              Text('CASHBACK', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildReferralSection(Color accentPurple, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161D29),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.group_outlined, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          const Text('Share the Energy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Refer a friend and both of you earn ₹15 in ShopVerse credits when they complete their first purchase.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share, size: 16),
            label: const Text('SHARE TO EARN'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentPurple,
              foregroundColor: bgColor,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCartButton(Product product, BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final isInCart = cart.items.containsKey(product.id);
        return GestureDetector(
          onTap: () {
            if (!isInCart) {
              cart.addItem(product);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(isInCart ? Icons.check : Icons.shopping_bag_outlined, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  isInCart ? 'IN CART' : 'ADD TO CART',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuyNowButton(Color accentPurple, Color bgColor) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPurple,
          foregroundColor: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('BUY NOW', style: TextStyle(fontWeight: FontWeight.w900)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
