import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/wishlist_provider.dart';
import 'package:shopverse/providers/location_provider.dart';
import 'package:shopverse/search_screen.dart';
import 'package:shopverse/product_details_screen.dart';
import 'package:shopverse/services/ai_service.dart';
import 'package:shopverse/providers/product_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandRed = Color(0xFFFF3232);
    final productProv = Provider.of<ProductProvider>(context);
    final allProducts = productProv.products;
    final recommended = AIService.getRecommendations(allProducts);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildBlinkitHeader(context, brandRed),
            _buildStickySearch(context, brandRed),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildPromotionBanner(),
                  _buildCategoryGrid(),

                  // AI Recommendations Section
                  _buildSectionHeader('Recommended for You', 'Picked by ShopVerse AI', brandRed, isAI: true),
                  _buildHorizontalRecommendations(context, recommended),

                  _buildSectionHeader('Bestsellers', 'Trending items', brandRed),
                  _buildHorizontalList(context, allProducts),
                  _buildSectionHeader('Daily Staples', 'Fresh & Essential', brandRed),
                  _buildVerticalGrid(context, allProducts),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color brandRed, {bool isAI = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isAI) ...[
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                  ],
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const Spacer(),
          Text('See all', style: TextStyle(color: brandRed, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHorizontalRecommendations(BuildContext context, List<Product> recommendations) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: recommendations.length,
        itemBuilder: (context, i) => _AiProductCard(product: recommendations[i]),
      ),
    );
  }

  Widget _buildBlinkitHeader(BuildContext context, Color brandRed) {
    return SliverToBoxAdapter(
      child: Consumer<LocationProvider>(
        builder: (context, locationProvider, _) {
          final address = locationProvider.selectedAddress;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [brandRed, brandRed.withValues(alpha: 0.8)],
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
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showLocationPicker(context, locationProvider),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Delivery in ${address.deliveryTimeMinutes} mins',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                          ],
                        ),
                        Text(
                          '${address.label} - ${address.addressLine}, ${address.area}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.person_outline, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLocationPicker(BuildContext context, LocationProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Change Location',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Use Current Location Button
                  InkWell(
                    onTap: provider.isFetchingLocation ? null : () async {
                      await provider.fetchCurrentLocation();
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3232).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF3232).withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location, color: Color(0xFFFF3232)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Use current location', style: TextStyle(color: Color(0xFFFF3232), fontWeight: FontWeight.bold)),
                                Text(
                                  provider.isFetchingLocation ? 'Detecting...' : 'Using GPS to find your address',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (provider.isFetchingLocation)
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF3232))),
                        ],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('SAVED ADDRESSES', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      itemCount: provider.addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final address = provider.addresses[index];
                        final isSelected = provider.selectedAddress.id == address.id;
                        
                        return InkWell(
                          onTap: () {
                            provider.selectAddress(index);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFF3232).withValues(alpha: 0.02) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFF3232) : Colors.grey.withValues(alpha: 0.2),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected ? const Color(0xFFFF3232) : Colors.grey[100],
                                  child: Icon(
                                    address.label == 'Home' ? Icons.home : (address.label == 'Work' ? Icons.work : Icons.location_on),
                                    color: isSelected ? Colors.white : Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address.label,
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isSelected ? const Color(0xFFFF3232) : Colors.black),
                                      ),
                                      Text(
                                        '${address.addressLine}, ${address.area}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Color(0xFFFF3232)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAddressDialog(context, provider),
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('ADD NEW ADDRESS', style: TextStyle(fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddAddressDialog(BuildContext context, LocationProvider provider) {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final areaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Address', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: labelController, decoration: const InputDecoration(labelText: 'Label (e.g. Other, Gym)')),
            const SizedBox(height: 12),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address Line')),
            const SizedBox(height: 12),
            TextField(controller: areaController, decoration: const InputDecoration(labelText: 'Area/Sector')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (labelController.text.isNotEmpty && addressController.text.isNotEmpty) {
                provider.addAddress(labelController.text, addressController.text, areaController.text);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildStickySearch(BuildContext context, Color brandRed) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickySearchDelegate(brandRed),
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
        image: const DecorationImage(
          image: NetworkImage('https://www.transparentpng.com/download/food/vegetables-png-images-free-download-23.png'),
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
        itemBuilder: (context, i) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchScreen(initialQuery: categories[i]['n'] as String),
              ),
            );
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: (categories[i]['c'] as Color).withValues(alpha: 0.15),
                child: Icon(categories[i]['i'] as IconData, color: categories[i]['c'] as Color),
              ),
              const SizedBox(height: 8),
              Text(categories[i]['n'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<Product> products) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        itemBuilder: (context, i) => _ProductCard(product: products[i]),
      ),
    );
  }

  Widget _buildVerticalGrid(BuildContext context, List<Product> products) {
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
        itemCount: products.length,
        itemBuilder: (context, i) => _ProductCard(product: products[i]),
      ),
    );
  }
}

class _AiProductCard extends StatelessWidget {
  final Product product;
  const _AiProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
      child: Container(
        width: 140,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
          border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final Color brandRed;
  _StickySearchDelegate(this.brandRed);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
      child: Container(
        color: brandRed,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
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
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
      child: Container(
        width: 160,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
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
                      _AddButtonSmall(product: product),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
        final cartItem = cart.items[product.id];
        final isInCart = cartItem != null;

        if (!isInCart) {
          return GestureDetector(
            onTap: () => cart.addItem(product),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF3232)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3232).withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Text(
                'ADD',
                style: TextStyle(
                  color: Color(0xFFFF3232),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF3232),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => cart.removeSingleItem(product.id),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Icon(Icons.remove, color: Colors.white, size: 16),
                ),
              ),
              Text(
                '${cartItem.quantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              GestureDetector(
                onTap: () => cart.addItem(product),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
