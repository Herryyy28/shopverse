import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/screens/shop/product_details_screen.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/services/ai_service.dart';
import 'package:shopverse/widgets/barcode_scanner_dialog.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

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
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  List<String> _searchHistory = [];
  List<String> _aiSuggestions = [];
  final ImagePicker _picker = ImagePicker();

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
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
            _onSearchChanged(result.recognizedWords);
            if (result.finalResult) {
              _isListening = false;
              _saveSearchHistory(result.recognizedWords);
            }
          });
        },
      );
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
      // Show analyzing loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.brandRed)),
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

  void _onSearchChanged(String query) async {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      final suggestions = await AIService.getSearchSuggestions(query);
      setState(() {
        _aiSuggestions = suggestions;
        _filteredProducts = _allProducts
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()) || 
                         p.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('ShopVerse', style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(icon: Icon(_isListening ? Icons.graphic_eq : Icons.mic, color: AppColors.brandRed), onPressed: _startListening),
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: AppColors.textPrimary), onPressed: _scanBarcode),
          IconButton(icon: const Icon(Icons.image_outlined, color: AppColors.textPrimary), onPressed: _pickImage),
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
                hintText: _isListening ? 'Listening...' : 'Search products, brands...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      }) 
                  : IconButton(icon: const Icon(Icons.mic, color: AppColors.textMuted), onPressed: _startListening),
              ),
            ),
          ),
          
          if (_isSearching && _aiSuggestions.isNotEmpty)
            _buildAISuggestions(),
          
          if (!_isSearching) ...[
            if (_searchHistory.isNotEmpty) _buildSearchHistory(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildFilterChip('Delivery Speed', AppColors.brandRed, true, Icons.bolt),
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
                  Icon(Icons.trending_up, color: AppColors.brandRed, size: 20),
                  SizedBox(width: 8),
                  Text('Trending Searches', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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
                Text('AI SUGGESTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple)),
              ],
            ),
          ),
          ..._aiSuggestions.map((s) => ListTile(
            leading: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
            title: Text(s, style: const TextStyle(fontSize: 14)),
            dense: true,
            onTap: () {
              _searchController.text = s;
              _onSearchChanged(s);
              _saveSearchHistory(s);
            },
          )),
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
              const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('search_history');
                  setState(() => _searchHistory = []);
                },
                child: const Text('Clear', style: TextStyle(fontSize: 12, color: AppColors.brandRed)),
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
                label: Text(_searchHistory[i], style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[200]!)),
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
                      style: const TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(width: 4),
                    if (product.oldPrice > product.price)
                      Text(
                        '₹${product.oldPrice.toInt()}',
                        style: const TextStyle(color: AppColors.textMuted, decoration: TextDecoration.lineThrough, fontSize: 11),
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
                      Provider.of<CartProvider>(context, listen: false).addItem(product);
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
