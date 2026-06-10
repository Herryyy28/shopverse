import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/product.dart';
import 'product_details_screen.dart';
import 'providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _onSearchChanged(widget.initialQuery!);
    }
  }

  // Updated Mock database for search with modern items
  static final List<Product> _allProducts = [
    Product(
      id: 'p0',
      name: 'Aura Pro Wireless Headphones - Midnight Purple',
      brand: 'AURA',
      description: 'Experience immersive sound with active noise cancellation and 40-hour battery life.',
      price: 299.0,
      oldPrice: 349.0,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
      category: 'Electronics',
      rating: 4.8,
      reviews: 1240,
    ),
    Product(
      id: 'p00',
      name: 'Chronos Classic Steel Edition',
      brand: 'CHRONOS',
      description: 'Timeless design meets modern precision. Sapphire glass and genuine leather strap.',
      price: 185.0,
      oldPrice: 220.0,
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
      category: 'Accessories',
      rating: 4.7,
      reviews: 850,
    ),
    Product(
      id: 'p000',
      name: 'Swift-Run Nitro Pro - Crimson',
      brand: 'SWIFT',
      description: 'Ultra-lightweight running shoes with Nitro-foam technology for maximum energy return.',
      price: 120.0,
      oldPrice: 150.0,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
      category: 'Footwear',
      rating: 4.9,
      reviews: 2100,
    ),
    Product(
      id: 'p0000',
      name: 'Horizon Wayfarer - Tortoise Shell',
      brand: 'HORIZON',
      description: 'Handcrafted acetate frames with polarized lenses for 100% UV protection.',
      price: 75.0,
      oldPrice: 95.0,
      imageUrl: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800',
      category: 'Accessories',
      rating: 4.6,
      reviews: 540,
    ),
    Product(
      id: 'p1',
      name: 'Amul Taaza Milk',
      description: 'Fresh toned milk',
      price: 27.0,
      oldPrice: 30.0,
      imageUrl: 'https://www.amul.com/files/products/Taaza_1L_Front.jpg',
      category: 'Dairy',
      unit: '500 ml',
    ),
  ];

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredProducts = _allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()) || 
                       p.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFFF3232);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ShopVerse', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.mic, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products, brands...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: const Icon(Icons.mic, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          if (!_isSearching) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildFilterChip('Delivery Speed', themeColor, true, Icons.bolt),
                  const SizedBox(width: 8),
                  _buildFilterChip('Price', Colors.grey[200]!, false, Icons.keyboard_arrow_down),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rating', Colors.grey[200]!, false, Icons.star_border),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: Color(0xFFFF3232), size: 20),
                  SizedBox(width: 8),
                  Text('Trending Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            
            _buildTrendingSearches(),
          ],

          Expanded(
            child: _isSearching 
              ? _filteredProducts.isEmpty
                  ? _buildNoResults()
                  : _buildSearchResults()
              : _buildRecentItemsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color, bool isSelected, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color : color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (isSelected) Icon(icon, color: Colors.white, size: 16),
          if (isSelected) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          if (!isSelected) const SizedBox(width: 4),
          if (!isSelected) Icon(icon, color: Colors.black87, size: 16),
        ],
      ),
    );
  }

  Widget _buildTrendingSearches() {
    final trends = ['Wireless Headphones', 'Smart Watches', 'Gaming Laptops', 'Skincare Sets'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: trends.map((s) => _buildRecentSearchChip(s)).toList(),
      ),
    );
  }

  Widget _buildRecentSearchChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildRecentItemsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final product = _allProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white70,
                  radius: 16,
                  child: Icon(Icons.favorite_border, size: 20, color: Colors.black87),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₹${product.price.toInt()}',
                      style: const TextStyle(color: Color(0xFFFF3232), fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(width: 4),
                    if (product.oldPrice > product.price)
                      Text(
                        '₹${product.oldPrice.toInt()}',
                        style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 11),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 4),
                        Text('Add to Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No products found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Try searching for something else', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ListTile(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.contain),
          ),
          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${product.unit} • ₹${product.price.toInt()}'),
          trailing: const Icon(Icons.chevron_right, size: 18),
        );
      },
    );
  }
}
