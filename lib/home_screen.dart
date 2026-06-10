import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/product.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Product> _products = [
    Product(
      id: 'p1',
      name: 'Amul Taaza Milk',
      description: 'Fresh toned milk',
      price: 27.0,
      oldPrice: 30.0,
      imageUrl: 'https://www.amul.com/files/products/Taaza_1L_Front.jpg',
      category: 'Dairy',
      unit: '500 ml',
      rating: 4.8,
      isVeg: true,
    ),
    Product(
      id: 'p2',
      name: 'Fortune Sunlite Sunflower Oil',
      description: 'Refined sunflower oil',
      price: 145.0,
      oldPrice: 175.0,
      imageUrl: 'https://m.media-amazon.com/images/I/71p0WfB6LHL._SL1500_.jpg',
      category: 'Grocery',
      unit: '1 L',
      rating: 4.5,
      isVeg: true,
    ),
    Product(
      id: 'p3',
      name: 'Aashirvaad Superior MP Atta',
      description: 'Whole wheat flour',
      price: 245.0,
      oldPrice: 280.0,
      imageUrl: 'https://m.media-amazon.com/images/I/81RAtC9zU2L._SL1500_.jpg',
      category: 'Grocery',
      unit: '5 kg',
      rating: 4.9,
      isVeg: true,
    ),
    Product(
      id: 'p4',
      name: 'Lay\'s India\'s Magic Masala',
      description: 'Spicy potato chips',
      price: 20.0,
      oldPrice: 20.0,
      imageUrl: 'https://m.media-amazon.com/images/I/71Yy3+M1vDL._SL1500_.jpg',
      category: 'Snacks',
      unit: '50 g',
      rating: 4.2,
      isVeg: true,
    ),
    Product(
      id: 'p5',
      name: 'Maggi 2-Minute Noodles',
      description: 'Instant noodles',
      price: 14.0,
      oldPrice: 16.0,
      imageUrl: 'https://m.media-amazon.com/images/I/81Xn9-iN9LL._SL1500_.jpg',
      category: 'Munchies',
      unit: '70 g',
      rating: 4.7,
      isVeg: true,
    ),
    Product(
      id: 'p6',
      name: 'Coca-Cola Soft Drink',
      description: 'Cold drink',
      price: 40.0,
      oldPrice: 45.0,
      imageUrl: 'https://m.media-amazon.com/images/I/51v8ny56SGL._SL1000_.jpg',
      category: 'Cold Drinks',
      unit: '750 ml',
      rating: 4.4,
      isVeg: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildBlinkitHeader(context),
            _buildStickySearch(context),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildPromotionBanner(),
                  _buildCategoryGrid(),
                  _buildSectionHeader('Bestsellers', 'Trending items'),
                  _buildHorizontalList(context),
                  _buildSectionHeader('Daily Staples', 'Fresh & Essential'),
                  _buildVerticalGrid(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlinkitHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF3232), Color(0xFFFF5252)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.location_on, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Delivery in 8 mins',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                    ],
                  ),
                  Text(
                    'Home - Sector 45, Gurgaon...',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.person_outline, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickySearch(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickySearchDelegate(),
    );
  }

  Widget _buildPromotionBanner() {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: PageView(
        children: [
          _promoCard('GET 50% OFF', 'On your first 3 orders', 'USE CODE: SHOP50', Colors.orange),
          _promoCard('FRESH FRUITS', 'Organic & Handpicked', 'SHOP NOW', Colors.green),
        ],
      ),
    );
  }

  Widget _promoCard(String title, String sub, String code, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: const NetworkImage('https://www.transparentpng.com/download/food/vegetables-png-images-free-download-23.png'),
          fit: BoxFit.fitHeight,
          alignment: Alignment.centerRight,
          opacity: 0.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
          Text(sub, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Text(code, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'n': 'Veggies', 'i': Icons.eco, 'c': Colors.green},
      {'n': 'Dairy', 'i': Icons.water_drop, 'c': Colors.blue},
      {'n': 'Snacks', 'i': Icons.fastfood, 'c': Colors.orange},
      {'n': 'Drinks', 'i': Icons.local_drink, 'c': Colors.cyan},
      {'n': 'Beauty', 'i': Icons.face, 'c': Colors.pink},
      {'n': 'Home', 'i': Icons.home, 'c': Colors.indigo},
      {'n': 'Pharma', 'i': Icons.medication, 'c': Colors.red},
      {'n': 'More', 'i': Icons.grid_view, 'c': Colors.grey},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, i) => Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: (categories[i]['c'] as Color).withOpacity(0.15),
              child: Icon(categories[i]['i'] as IconData, color: categories[i]['c'] as Color),
            ),
            const SizedBox(height: 8),
            Text(categories[i]['n'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const Spacer(),
          const Text('See all', style: TextStyle(color: Color(0xFFFF3232), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _products.length,
        itemBuilder: (context, i) => _ProductCard(product: _products[i]),
      ),
    );
  }

  Widget _buildVerticalGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _products.length,
        itemBuilder: (context, i) => _ProductCard(product: _products[i]),
      ),
    );
  }
}

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFFF3232),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Text('Search "chips"', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
            const Spacer(),
            const Icon(Icons.mic_none, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;
  @override
  double get minExtent => 60;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        placeholder: (c, u) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (c, u, e) => const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                      ),
                      child: Text('${product.discount}% OFF', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlist, _) => GestureDetector(
                      onTap: () => wishlist.toggleWishlist(product),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: Icon(
                          wishlist.isFavorite(product.id) ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        border: Border.all(color: product.isVeg ? Colors.green : Colors.red, width: 1.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: CircleAvatar(radius: 2, backgroundColor: product.isVeg ? Colors.green : Colors.red),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(product.unit, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.oldPrice > product.price)
                          Text('₹${product.oldPrice.toInt()}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11)),
                        Text('₹${product.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      ],
                    ),
                    _AddButton(product: product),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final Product product;
  const _AddButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final cartItem = cart.items[product.id];
        if (cartItem == null) {
          return GestureDetector(
            onTap: () => cart.addItem(product),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3232).withOpacity(0.1),
                border: Border.all(color: const Color(0xFFFF3232)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('ADD', style: TextStyle(color: Color(0xFFFF3232), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF3232),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                onPressed: () => cart.removeSingleItem(product.id),
              ),
              Text('${cartItem.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              IconButton(
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                onPressed: () => cart.addItem(product),
              ),
            ],
          ),
        );
      },
    );
  }
}
