import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/wishlist_provider.dart';
import 'package:shopverse/providers/location_provider.dart';
import 'package:shopverse/providers/recent_provider.dart';
import 'package:shopverse/search_screen.dart';
import 'package:shopverse/product_details_screen.dart';
import 'package:shopverse/services/ai_service.dart';
import 'package:shopverse/services/firebase_service.dart';
import 'package:shopverse/providers/product_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';
import 'package:shopverse/widgets/custom_text_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  StreamSubscription? _flashSaleSubscription;

  @override
  void initState() {
    super.initState();
    _initFlashSaleSync();
  }

  void _initFlashSaleSync() {
    _flashSaleSubscription = FirebaseService.getFlashSaleEndTime().listen((endTime) {
      _startTimer(endTime);
    });
  }

  void _startTimer(DateTime endTime) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (endTime.isAfter(now)) {
        setState(() {
          _timeLeft = endTime.difference(now);
        });
      } else {
        setState(() {
          _timeLeft = Duration.zero;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flashSaleSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: StreamBuilder<List<Product>>(
          stream: productProv.productsStream,
          builder: (context, snapshot) {
            final allProducts = snapshot.data ?? productProv.products;
            final recommended = AIService.getRecommendations(allProducts);
            final newlyAdded = allProducts.reversed.take(5).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildBlinkitHeader(context),
                _buildStickySearch(context),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildPromotionBanner(),
                      _buildCategoryGrid(),
                      _buildFlashSaleTimer(context),

                      if (newlyAdded.isNotEmpty) ...[
                        _buildSectionHeader('Newly Added', 'Fresh in stock!'),
                        _buildHorizontalList(context, newlyAdded),
                      ],

                      // Recently Viewed Section
                      Consumer<RecentProvider>(
                        builder: (context, recentProv, _) {
                          if (recentProv.recentlyViewed.isEmpty) return const SizedBox.shrink();
                          return Column(
                            children: [
                              _buildSectionHeader('Recently Viewed', 'Pick up where you left off'),
                              _buildHorizontalList(context, recentProv.recentlyViewed),
                            ],
                          );
                        },
                      ),

                      _buildSectionHeader('Recommended for You', 'Picked by ShopVerse AI', isAI: true),
                      _buildHorizontalRecommendations(context, recommended),

                      _buildSectionHeader('Daily Deals', 'Exclusive offers just for you'),
                      _buildDailyDealsGrid(context, allProducts.take(4).toList()),

                      _buildSectionHeader('Bestsellers', 'Trending items'),
                      _buildHorizontalList(context, allProducts),
                      _buildSectionHeader('Daily Staples', 'Fresh & Essential'),
                      _buildVerticalGrid(context, allProducts),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, {bool isAI = false}) {
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
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const Spacer(),
          const Text('See all', style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.bold)),
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

  Widget _buildBlinkitHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<LocationProvider>(
        builder: (context, locationProvider, _) {
          final address = locationProvider.selectedAddress;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.brandRed, AppColors.brandRed.withValues(alpha: 0.8)],
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
                        color: AppColors.brandRed.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location, color: AppColors.brandRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Use current location', style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.bold)),
                                Text(
                                  provider.isFetchingLocation ? 'Detecting...' : 'Using GPS to find your address',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (provider.isFetchingLocation)
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandRed)),
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
                          child: Text('SAVED ADDRESSES', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
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
                              color: isSelected ? AppColors.brandRed.withValues(alpha: 0.02) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.brandRed : Colors.grey.withValues(alpha: 0.2),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected ? AppColors.brandRed : Colors.grey[100],
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
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isSelected ? AppColors.brandRed : AppColors.textPrimary),
                                      ),
                                      Text(
                                        '${address.addressLine}, ${address.area}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: AppColors.brandRed),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'ADD NEW ADDRESS',
                    onPressed: () => _showAddAddressDialog(context, provider),
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
            CustomTextField(controller: labelController, label: 'Label (e.g. Other, Gym)'),
            const SizedBox(height: 12),
            CustomTextField(controller: addressController, label: 'Address Line'),
            const SizedBox(height: 12),
            CustomTextField(controller: areaController, label: 'Area/Sector'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary))),
          SizedBox(
            width: 100,
            child: CustomButton(
              text: 'SAVE',
              onPressed: () {
                if (labelController.text.isNotEmpty && addressController.text.isNotEmpty) {
                  provider.addAddress(labelController.text, addressController.text, areaController.text);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close bottom sheet
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickySearch(BuildContext context) {
    return const SliverPersistentHeader(
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

  Widget _buildDailyDealsGrid(BuildContext context, List<Product> deals) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: deals.length,
        itemBuilder: (context, i) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 400 + (i * 100)),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          [Colors.blue, Colors.purple, Colors.orange, Colors.teal][i % 4].withValues(alpha: 0.1),
                          [Colors.blue, Colors.purple, Colors.orange, Colors.teal][i % 4].withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(color: [Colors.blue, Colors.purple, Colors.orange, Colors.teal][i % 4].withValues(alpha: 0.2)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: Opacity(
                            opacity: 0.5,
                            child: CachedNetworkImage(imageUrl: deals[i].imageUrl, width: 80),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(deals[i].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1),
                              const SizedBox(height: 4),
                              Text('Flat ₹${(deals[i].oldPrice - deals[i].price).toInt()} OFF', style: TextStyle(color: [Colors.blue, Colors.purple, Colors.orange, Colors.teal][i % 4], fontWeight: FontWeight.w900, fontSize: 12)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                child: const Text('GRAB NOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
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

  Widget _buildFlashSaleTimer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF416C).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flash Sale Ending In',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _TimerBox(value: _formatDuration(_timeLeft.inHours)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    _TimerBox(value: _formatDuration(_timeLeft.inMinutes % 60)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    _TimerBox(value: _formatDuration(_timeLeft.inSeconds % 60)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'View All',
              style: TextStyle(color: Color(0xFFFF416C), fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerBox extends StatelessWidget {
  final String value;
  const _TimerBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
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
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
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
  const _StickySearchDelegate();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
      child: Container(
        color: AppColors.brandRed,
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
              const Icon(Icons.search, color: AppColors.textMuted),
              const SizedBox(width: 12),
              const Text('Search "chips"', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
              const Spacer(),
              const Icon(Icons.mic_none, color: AppColors.textMuted),
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
                            color: AppColors.brandRed,
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
                      Text(product.unit, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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
                            const Text('₹', style: TextStyle(decoration: TextDecoration.lineThrough, color: AppColors.textSecondary, fontSize: 11)),
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
                border: Border.all(color: AppColors.brandRed),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandRed.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Text(
                'ADD',
                style: TextStyle(
                  color: AppColors.brandRed,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.brandRed,
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
