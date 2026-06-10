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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
          Consumer<WishlistProvider>(
            builder: (context, wishlist, _) => IconButton(
              icon: Icon(
                wishlist.isFavorite(product.id) ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () => wishlist.toggleWishlist(product),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  color: Colors.white,
                  child: Hero(
                    tag: 'product-${product.id}',
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (c, u, e) => const Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey),
                    ),
                  ),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.discount}% OFF',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          border: Border.all(color: product.isVeg ? Colors.green : Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(
                          child: CircleAvatar(radius: 3, backgroundColor: product.isVeg ? Colors.green : Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(product.category, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.unit,
                    style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${product.price.toInt()}',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 10),
                      if (product.oldPrice > product.price)
                        Text(
                          'MRP ₹${product.oldPrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const Text(
                    '(Inclusive of all taxes)',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Product Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  _buildDetailRow('Description', product.description),
                  _buildDetailRow('Unit', product.unit),
                  _buildDetailRow('Shelf Life', '6 Months'),
                  _buildDetailRow('Manufacturer', 'ShopVerse Private Limited'),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${product.price.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const Text('TOTAL PRICE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _AddButtonLarge(product: product),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

class _AddButtonLarge extends StatelessWidget {
  final Product product;
  const _AddButtonLarge({required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final cartItem = cart.items[product.id];
        if (cartItem == null) {
          return SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () => cart.addItem(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3232),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('ADD TO CART', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          );
        }
        return Container(
          width: 150,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFF3232),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () => cart.removeSingleItem(product.id),
              ),
              Text('${cartItem.quantity}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => cart.addItem(product),
              ),
            ],
          ),
        );
      },
    );
  }
}
