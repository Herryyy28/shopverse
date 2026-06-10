import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/providers/wishlist_provider.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/product_details_screen.dart';
import 'package:shopverse/models/product.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final wishlistItems = wishlist.items.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (wishlistItems.isNotEmpty)
            IconButton(
              onPressed: () => _showClearDialog(context, wishlist),
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF3232)),
            ),
        ],
      ),
      body: wishlistItems.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final product = wishlistItems[index];
                return _buildWishlistItem(context, product, wishlist, cart);
              },
            ),
    );
  }

  Widget _buildWishlistItem(BuildContext context, Product product, WishlistProvider wishlist, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(product.unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('₹${product.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(width: 8),
                        if (product.oldPrice > product.price)
                          Text('₹${product.oldPrice.toInt()}', 
                            style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => wishlist.removeItem(product.id),
                  ),
                  _AddButtonSmall(product: product),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Your wishlist is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Save items to buy them later', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3232)),
            child: const Text('EXPLORE PRODUCTS'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WishlistProvider wishlist) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Wishlist?'),
        content: const Text('Remove all items from your wishlist?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              wishlist.clear();
              Navigator.pop(ctx);
            },
            child: const Text('CLEAR ALL', style: TextStyle(color: Color(0xFFFF3232))),
          ),
        ],
      ),
    );
  }
}

class _AddButtonSmall extends StatelessWidget {
  final Product product;
  const _AddButtonSmall({required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final isInCart = cart.items.containsKey(product.id);
        return GestureDetector(
          onTap: () {
            if (!isInCart) {
              cart.addItem(product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to bag'), duration: Duration(milliseconds: 500)),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isInCart ? Colors.grey[200] : const Color(0xFFFF3232).withValues(alpha: 0.1),
              border: Border.all(color: isInCart ? Colors.grey : const Color(0xFFFF3232)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isInCart ? 'IN BAG' : 'ADD',
              style: TextStyle(
                color: isInCart ? Colors.grey : const Color(0xFFFF3232),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        );
      },
    );
  }
}
