import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/screens/shop/product_details_screen.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/services/ai_service.dart';
import 'package:shopverse/widgets/barcode_scanner_dialog.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';
import 'package:shopverse/widgets/voice_visualizer_dialog.dart';

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

  // Advanced Search States

  List<String> _searchHistory = [];
  List<String> _aiSuggestions = [];
  final ImagePicker _picker = ImagePicker();

  // Filter & Sort state
  String _sortBy = 'relevance';
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _minRating = 0;
  bool _inStockOnly = false;
  bool _onSaleOnly = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _onSearchChanged(widget.initialQuery!);
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 10) _searchHistory.removeLast();
    await prefs.setStringList('search_history', _searchHistory);
    setState(() {});
  }

  Future<void> _startListening() async {
    final query = await showDialog<String>(
      context: context,
      builder: (context) => const VoiceVisualizerDialog(),
    );
    if (query != null && query.isNotEmpty) {
      setState(() {
        _searchController.text = query;
        _onSearchChanged(query);
        _saveSearchHistory(query);
      });
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerDialog()),
    );
    if (result != null) {
      _searchController.text = result.toString();
      _onSearchChanged(result.toString());
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      // Show analyzing loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: AppColors.brandRed),
        ),
      );

      final tags = await AIService.analyzeImage(image.path);
      if (mounted) Navigator.pop(context); // Close loader

      if (tags.isNotEmpty) {
        _searchController.text = tags.first;
        _onSearchChanged(tags.first);
      }
    }
  }

  // Updated Mock database for search with modern items
  static final List<Product> _allProducts = [
    Product(
      id: 'p0',
      name: 'Aura Pro Wireless Headphones - Midnight Purple',
      brand: 'AURA',
      description:
          'Experience immersive sound with active noise cancellation and 40-hour battery life.',
      price: 299.0,
      oldPrice: 349.0,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
      category: 'Electronics',
      rating: 4.8,
      reviews: 1240,
    ),
    Product(
      id: 'p00',
      name: 'Chronos Classic Steel Edition',
      brand: 'CHRONOS',
      description:
          'Timeless design meets modern precision. Sapphire glass and genuine leather strap.',
      price: 185.0,
      oldPrice: 220.0,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
      category: 'Accessories',
      rating: 4.7,
      reviews: 850,
    ),
    Product(
      id: 'p000',
      name: 'Swift-Run Nitro Pro - Crimson',
      brand: 'SWIFT',
      description:
          'Ultra-lightweight running shoes with Nitro-foam technology for maximum energy return.',
      price: 120.0,
      oldPrice: 150.0,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
      category: 'Footwear',
      rating: 4.9,
      reviews: 2100,
    ),
    Product(
      id: 'p0000',
      name: 'Horizon Wayfarer - Tortoise Shell',
      brand: 'HORIZON',
      description:
          'Handcrafted acetate frames with polarized lenses for 100% UV protection.',
      price: 75.0,
      oldPrice: 95.0,
      imageUrl:
          'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800',
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
      imageUrl:
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=800',
      category: 'Dairy',
      unit: '500 ml',
    ),
  ];

  void _onSearchChanged(String query) async {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      final suggestions = await AIService.getSearchSuggestions(query);
      setState(() {
        _aiSuggestions = suggestions;
        _filteredProducts = _allProducts
            .where(
              (p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  p.category.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'ShopVerse',
          style: TextStyle(
            color: AppColors.brandRed,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: AppColors.brandRed),
            onPressed: _startListening,
          ),
          IconButton(
            icon: const Icon(
              Icons.qr_code_scanner,
              color: AppColors.textPrimary,
            ),
            onPressed: _scanBarcode,
          ),
          IconButton(
            icon: const Icon(
              Icons.image_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: _pickImage,
          ),
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
              onSubmitted: _saveSearchHistory,
              decoration: InputDecoration(
                hintText: 'Search products, brands...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.mic, color: AppColors.textMuted),
                        onPressed: _startListening,
                      ),
              ),
            ),
          ),

          // Filter & Sort bar (visible when searching)
          if (_isSearching)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  _buildSortButton(),
                  const SizedBox(width: 8),
                  _buildFilterButton(),
                  const SizedBox(width: 8),
                  if (_onSaleOnly ||
                      _minRating > 0 ||
                      _priceRange.start > 0 ||
                      _priceRange.end < 1000)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _priceRange = const RangeValues(0, 1000);
                          _minRating = 0;
                          _inStockOnly = false;
                          _onSaleOnly = false;
                          _sortBy = 'relevance';
                          _onSearchChanged(_searchController.text);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.clear, size: 14, color: Colors.red),
                            SizedBox(width: 4),
                            Text(
                              'Clear',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

          if (_isSearching && _aiSuggestions.isNotEmpty) _buildAISuggestions(),

          if (!_isSearching) ...[
            if (_searchHistory.isNotEmpty) _buildSearchHistory(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildFilterChip(
                    'Delivery Speed',
                    AppColors.brandRed,
                    true,
                    Icons.bolt,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Price',
                    Colors.grey[200]!,
                    false,
                    Icons.keyboard_arrow_down,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Rating',
                    Colors.grey[200]!,
                    false,
                    Icons.star_border,
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.brandRed, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Trending Searches',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
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

  Widget _buildAISuggestions() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple, size: 16),
                SizedBox(width: 8),
                Text(
                  'AI SUGGESTIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          ..._aiSuggestions.map(
            (s) => ListTile(
              leading: const Icon(
                Icons.search,
                size: 18,
                color: AppColors.textMuted,
              ),
              title: Text(s, style: const TextStyle(fontSize: 14)),
              dense: true,
              onTap: () {
                _searchController.text = s;
                _onSearchChanged(s);
                _saveSearchHistory(s);
              },
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('search_history');
                  setState(() => _searchHistory = []);
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(fontSize: 12, color: AppColors.brandRed),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _searchHistory.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                label: Text(
                  _searchHistory[i],
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                onPressed: () {
                  _searchController.text = _searchHistory[i];
                  _onSearchChanged(_searchHistory[i]);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    Color color,
    bool isSelected,
    IconData icon,
  ) {
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
    final trends = [
      'Wireless Headphones',
      'Smart Watches',
      'Gaming Laptops',
      'Skincare Sets',
    ];
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
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecentItemsGrid() {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 900 ? 5 : (width > 600 ? 3 : 2);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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
                  child: Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Colors.black87,
                  ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₹${product.price.toInt()}',
                      style: const TextStyle(
                        color: AppColors.brandRed,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (product.oldPrice > product.price)
                      Text(
                        '₹${product.oldPrice.toInt()}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: CustomButton(
                    text: 'ADD',
                    onPressed: () {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).addItem(product);
                    },
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
          const Text(
            'No products found',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'Try searching for something else',
            style: TextStyle(color: Colors.grey[600]),
          ),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            ),
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
          title: Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              Text('${product.unit} • ₹${product.price.toInt()}'),
              const SizedBox(width: 8),
              if (product.rating > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${product.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.star, size: 10, color: Colors.white),
                    ],
                  ),
                ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, size: 18),
        );
      },
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort By',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  ...[
                    {
                      'key': 'relevance',
                      'label': 'Relevance',
                      'icon': Icons.auto_awesome,
                    },
                    {
                      'key': 'price_low',
                      'label': 'Price: Low to High',
                      'icon': Icons.arrow_upward,
                    },
                    {
                      'key': 'price_high',
                      'label': 'Price: High to Low',
                      'icon': Icons.arrow_downward,
                    },
                    {
                      'key': 'rating',
                      'label': 'Highest Rating',
                      'icon': Icons.star,
                    },
                    {
                      'key': 'newest',
                      'label': 'Newest First',
                      'icon': Icons.new_releases,
                    },
                    {
                      'key': 'discount',
                      'label': 'Highest Discount',
                      'icon': Icons.local_offer,
                    },
                  ].map((option) {
                    final isSelected = _sortBy == option['key'];
                    return ListTile(
                      leading: Icon(
                        option['icon'] as IconData,
                        color: isSelected
                            ? AppColors.brandRed
                            : AppColors.textMuted,
                        size: 20,
                      ),
                      title: Text(
                        option['label'] as String,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.brandRed
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.brandRed,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _sortBy = option['key'] as String;
                          _applySortAndFilter();
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _sortBy != 'relevance'
              ? AppColors.brandRed.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _sortBy != 'relevance'
                ? AppColors.brandRed
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 14,
              color: _sortBy != 'relevance'
                  ? AppColors.brandRed
                  : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              'Sort',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _sortBy != 'relevance'
                    ? AppColors.brandRed
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    final hasFilters =
        _priceRange.start > 0 ||
        _priceRange.end < 1000 ||
        _minRating > 0 ||
        _onSaleOnly;
    return GestureDetector(
      onTap: () => _showFilterSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasFilters
              ? AppColors.brandRed.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFilters ? AppColors.brandRed : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 14,
              color: hasFilters ? AppColors.brandRed : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: hasFilters ? AppColors.brandRed : AppColors.textPrimary,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.brandRed,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _priceRange = const RangeValues(0, 1000);
                            _minRating = 0;
                            _inStockOnly = false;
                            _onSaleOnly = false;
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: AppColors.brandRed),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Price Range
                  const Text(
                    'Price Range',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${_priceRange.start.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandRed,
                        ),
                      ),
                      Text(
                        '₹${_priceRange.end.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandRed,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    activeColor: AppColors.brandRed,
                    labels: RangeLabels(
                      '₹${_priceRange.start.toInt()}',
                      '₹${_priceRange.end.toInt()}',
                    ),
                    onChanged: (values) =>
                        setModalState(() => _priceRange = values),
                  ),
                  const SizedBox(height: 20),

                  // Minimum Rating
                  const Text(
                    'Minimum Rating',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [1, 2, 3, 4, 5].map((star) {
                      final isSelected = _minRating >= star;
                      return GestureDetector(
                        onTap: () => setModalState(
                          () => _minRating = _minRating == star.toDouble()
                              ? 0
                              : star.toDouble(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: isSelected ? Colors.amber : Colors.grey[300],
                            size: 36,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Toggle filters
                  SwitchListTile(
                    title: const Text(
                      'On Sale Only',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Show items with discounts'),
                    value: _onSaleOnly,
                    activeThumbColor: AppColors.brandRed,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setModalState(() => _onSaleOnly = v),
                  ),
                  SwitchListTile(
                    title: const Text(
                      'In Stock Only',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Hide out-of-stock items'),
                    value: _inStockOnly,
                    activeThumbColor: AppColors.brandRed,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setModalState(() => _inStockOnly = v),
                  ),

                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _applySortAndFilter());
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
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

  void _applySortAndFilter() {
    final query = _searchController.text.toLowerCase();
    var results = _allProducts.where((p) {
      final matchesQuery =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query) ||
          p.brand.toLowerCase().contains(query);
      final matchesPrice =
          p.price >= _priceRange.start && p.price <= _priceRange.end;
      final matchesRating = p.rating >= _minRating;
      final matchesSale = !_onSaleOnly || p.oldPrice > p.price;
      return matchesQuery && matchesPrice && matchesRating && matchesSale;
    }).toList();

    // Apply sort
    switch (_sortBy) {
      case 'price_low':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'discount':
        results.sort((a, b) => b.discount.compareTo(a.discount));
        break;
    }

    setState(() => _filteredProducts = results);
  }
}
