import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/wishlist_provider.dart';
import 'package:shopverse/providers/recent_provider.dart';
import 'package:shopverse/providers/compare_provider.dart';
import 'package:shopverse/screens/shop/comparison_screen.dart';
import 'package:shopverse/services/ai_service.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';
import 'package:shopverse/widgets/video_preview_dialog.dart';
import 'package:shopverse/widgets/view_360_dialog.dart';
import 'package:shopverse/widgets/ar_preview_dialog.dart';
import 'package:shopverse/widgets/price_tracker_widget.dart';
import 'package:shopverse/widgets/subscription_scheduler_dialog.dart';
import 'package:shopverse/widgets/bargain_arena_widget.dart';
import 'package:shopverse/widgets/drag_to_buy_slider.dart';
import 'package:shopverse/screens/shop/vendor_profile_screen.dart';
import 'package:shopverse/widgets/digital_wrapper_dialog.dart';
import 'package:shopverse/widgets/price_comparison_graph.dart';
import 'package:shopverse/screens/shop/ar_dimension_calculator.dart';
import 'package:shopverse/widgets/review_section_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  final Map<String, String> _selectedOptions = {};
  late PageController _pageController;
  
  String? get _currentARModelUrl {
    final selectedColor = _selectedOptions['Color'];
    if (selectedColor == 'Space Black') {
      return 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
    }
    return widget.product.arModelUrl;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Initialize default variants
    for (var variant in widget.product.variants) {
      if (variant.options.isNotEmpty) {
        _selectedOptions[variant.name] = variant.options.first;
      }
    }
    // Add to recently viewed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecentProvider>(context, listen: false).addProduct(widget.product);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onVariantSelected(String name, String option) {
    setState(() {
      _selectedOptions[name] = option;
      if (name.toLowerCase() == 'color') {
        final variant = widget.product.variants.firstWhere((v) => v.name.toLowerCase() == 'color');
        final index = variant.options.indexOf(option);
        if (index >= 0 && index < (widget.product.images.length + 1)) {
          _currentImageIndex = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final allImages = [product.imageUrl, ...product.images];
    const bgColor = AppColors.backgroundColor;
    const accentGreen = Color(0xFF00E676);
    const accentPurple = AppColors.brandRed;

    // Mock all products for AI service (In real app, this would come from a ProductProvider)
    final List<Product> allProducts = [
      product, // Include current product
      Product(
        id: 'p0',
        name: 'Neon Velocity G7 Pro',
        brand: 'APEX FOOTWEAR',
        description: 'Engineered for the neon-lit streets...',
        price: 189.0,
        oldPrice: 245.0,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
        category: 'Footwear',
      ),
      Product(
        id: 'p2',
        name: 'Fortune Sunlite Sunflower Oil',
        description: 'Refined sunflower oil',
        price: 145.0,
        oldPrice: 175.0,
        imageUrl: 'https://m.media-amazon.com/images/I/71p0WfB6LHL._SL1500_.jpg',
        category: 'Grocery',
      ),
      Product(
        id: 'p3',
        name: 'Aashirvaad Superior MP Atta',
        description: 'Whole wheat flour',
        price: 245.0,
        oldPrice: 280.0,
        imageUrl: 'https://m.media-amazon.com/images/I/81RAtC9zU2L._SL1500_.jpg',
        category: 'Grocery',
      ),
      Product(
        id: 'p5',
        name: 'Maggi 2-Minute Noodles',
        description: 'Instant noodles',
        price: 14.0,
        oldPrice: 16.0,
        imageUrl: 'https://m.media-amazon.com/images/I/81Xn9-iN9LL._SL1500_.jpg',
        category: 'Munchies',
      ),
    ];

    final recommended = AIService.getFrequentlyBoughtTogether(product, allProducts);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ShopVerse',
          style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.mic, color: AppColors.textPrimary), onPressed: () {}),
          Consumer<CompareProvider>(
            builder: (context, compareProv, _) {
              final isComparing = compareProv.isComparing(product.id);
              return IconButton(
                icon: Icon(
                  isComparing ? Icons.compare : Icons.compare_arrows,
                  color: isComparing ? AppColors.brandRed : AppColors.textPrimary,
                ),
                onPressed: () {
                  final error = compareProv.addProduct(product);
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isComparing ? 'Removed from comparison' : 'Added to comparison'),
                        backgroundColor: Colors.green,
                        action: SnackBarAction(
                          label: 'VIEW',
                          textColor: Colors.white,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ComparisonScreen()),
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
          Consumer<WishlistProvider>(
            builder: (context, wishlist, _) => IconButton(
              icon: Icon(
                wishlist.isFavorite(product.id) ? Icons.favorite : Icons.favorite_border,
                color: wishlist.isFavorite(product.id) ? Colors.red : AppColors.textPrimary,
              ),
              onPressed: () => wishlist.toggleWishlist(product),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textPrimary),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Share link copied: shopverse.app/product/${product.id}'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'SHARE',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section (Carousel)
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: allImages.length,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Color(0xFFF0F0F0)],
                          ),
                        ),
                        child: Hero(
                          tag: index == 0 ? 'product-${product.id}' : 'product-img-$index',
                          child: CachedNetworkImage(
                            imageUrl: allImages[index],
                            fit: BoxFit.contain,
                            placeholder: (c, u) => const Center(child: CircularProgressIndicator(color: AppColors.brandRed)),
                            errorWidget: (c, u, e) => const Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.black12),
                          ),
                        ),
                      );
                    },
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
                // Media Shortcuts (360, AR, Video)
                Positioned(
                  right: 20,
                  top: 20,
                  child: Column(
                    children: [
                      if (product.view360Url != null)
                        _buildMediaCircle(Icons.threesixty, '360°', () {
                          // Mocking a list of images for 360 view as product.view360Url would usually be a base path or sequence
                          final mock360Images = List.generate(8, (index) => 
                            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80' // Using same image for demo
                          );
                          showDialog(
                            context: context,
                            builder: (_) => View360Dialog(imageList: mock360Images),
                          );
                        }),
                      if (_currentARModelUrl != null)
                        const SizedBox(height: 12),
                      if (_currentARModelUrl != null)
                        _buildMediaCircle(Icons.view_in_ar, 'AR', () {
                          showDialog(
                            context: context,
                            builder: (_) => ARPreviewDialog(
                              modelUrl: _currentARModelUrl!,
                              productName: '${widget.product.name} (${_selectedOptions['Color'] ?? ''})',
                            ),
                          );
                        }),
                      if (product.videoUrl != null)
                        const SizedBox(height: 12),
                      if (product.videoUrl != null)
                        _buildMediaCircle(Icons.play_circle_outline, 'Video', () {
                          showDialog(
                            context: context,
                            builder: (_) => VideoPreviewDialog(videoUrl: product.videoUrl!),
                          );
                        }),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      allImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentImageIndex == index ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index ? AppColors.brandRed : Colors.black.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
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
                  Text(
                    product.brand.toUpperCase(),
                    style: const TextStyle(color: AppColors.textSecondary, letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorProfileScreen(vendorId: product.vendorId),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.storefront, size: 16, color: AppColors.brandRed),
                          const SizedBox(width: 8),
                          Text(
                            'Sold by ${product.vendorName}',
                            style: const TextStyle(color: AppColors.brandRed, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.brandRed),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating} • ${product.reviews} reviews',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Read All',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  if (product.variants.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select Variations', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: () async {
                            final recommendation = await AIService.getSizeRecommendation(product.id, {});
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(recommendation),
                                  backgroundColor: AppColors.brandRed,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.straighten, size: 16, color: AppColors.brandRed),
                          label: const Text('Size Guide', style: TextStyle(color: AppColors.brandRed, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...product.variants.map((variant) => _buildVariantSelector(variant)),
                    const SizedBox(height: 24),
                  ],

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '₹',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '${product.price.toInt()}',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 12),
                      if (product.oldPrice > product.price)
                        Text(
                          '₹${product.oldPrice.toInt()}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 18,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (product.discount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.discount}% OFF',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 14,
                          child: Icon(Icons.bolt, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FLASH DELIVERY',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  children: [
                                    TextSpan(text: 'Delivering to '),
                                    TextSpan(text: 'Home ', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                    TextSpan(text: 'in '),
                                    TextSpan(text: '15 mins', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
                  const Text('AI Shopping Assistant', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  _buildAIAssistantSection(),

                  const SizedBox(height: 32),
                  const Text('Fit Sizing Guide', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final sizeRec = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(builder: (_) => const ARDimensionCalculator()),
                      );
                      if (sizeRec != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calculated sizing: $sizeRec applied!'), backgroundColor: Colors.blueAccent),
                        );
                      }
                    },
                    icon: const Icon(Icons.center_focus_strong, color: Color(0xFF5B61F4)),
                    label: const Text('SCAN MY SIZE WITH AR', style: TextStyle(color: Color(0xFF5B61F4), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF5B61F4)),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  BargainArenaWidget(
                    originalPrice: product.price,
                    onPriceUpdated: (newPrice) {
                      // Trigger price slashes dynamically
                    },
                  ),
                  const SizedBox(height: 24),
                  PriceTrackerWidget(currentPrice: product.price, oldPrice: product.oldPrice),
                  const SizedBox(height: 24),
                  PriceComparisonGraph(currentPrice: product.price),
                  const SizedBox(height: 24),
                  
                  // Subscription scheduling trigger
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.repeat, color: Colors.amber),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ShopVerse Repeat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Schedule recurring automatic deliveries', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => SubscriptionSchedulerDialog(
                                productName: product.name,
                                price: product.price,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('SUBSCRIBE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Technical Specifications', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  _buildSpecificationsTable(product.specifications),

                  const SizedBox(height: 32),
                  ReviewSectionWidget(productId: product.id),
                  const SizedBox(height: 32),
                  _buildQASection(),

                  if (recommended.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text('AI Recommended Pairings', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommended.length,
                        itemBuilder: (context, index) {
                          final p = recommended[index];
                          return GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
                            ),
                            child: Container(
                              width: 280,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: p.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(p.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text('₹${p.price.toInt()}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        const Text('Frequently bought with this', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.add_circle_outline, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black12,
                          child: Text(product.brand[0], style: const TextStyle(color: AppColors.textPrimary)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${product.brand} Official Store', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                              const Row(
                                children: [
                                  Text('Verified Merchant', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  CircleAvatar(radius: 2, backgroundColor: Colors.black12),
                                  SizedBox(width: 8),
                                  Text('98% Positive', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            side: const BorderSide(color: Colors.black12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('FOLLOW', style: TextStyle(color: AppColors.textPrimary, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text('Instant Checkout Slider', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  DragToBuySlider(
                    price: product.price,
                    onConfirmed: () {
                      showDialog(
                        context: context,
                        builder: (_) => DigitalWrapperDialog(productName: product.name),
                      );
                    },
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

  Widget _buildMediaCircle(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.brandRed, size: 20),
            Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantSelector(ProductVariant variant) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(variant.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: variant.options.map((option) {
              final isSelected = _selectedOptions[variant.name] == option;
              return GestureDetector(
                onTap: () => _onVariantSelected(variant.name, option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandRed : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? AppColors.brandRed : Colors.black12),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAssistantSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withValues(alpha: 0.1), Colors.blue.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildAIActionTile(
            icon: Icons.compare_arrows,
            title: 'Compare with similar products',
            subtitle: 'Let AI find the best value for you',
            onTap: () async {
              final comparison = await AIService.getProductComparison(widget.product.id, 'similar_id');
              if (mounted) {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI Product Comparison', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...comparison.map((c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 12),
                              Expanded(child: Text(c)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          const Divider(),
          _buildAIActionTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Budget Optimization',
            subtitle: 'Is this the best time to buy?',
            onTap: () async {
              final suggestion = await AIService.getBudgetSuggestion(widget.product.price, widget.product.category);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(suggestion), backgroundColor: Colors.blue),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAIActionTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(icon, color: Colors.purple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSpecificationsTable(Map<String, String> specs) {
    if (specs.isEmpty) {
      return const Text('No detailed specifications available.', style: TextStyle(color: AppColors.textMuted));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: specs.entries.map((e) {
          final isLast = specs.keys.last == e.key;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: isLast ? null : Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(e.key, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(e.value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRatingsSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ratings & Reviews', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
            TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: AppColors.brandRed))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Column(
              children: [
                Text('${product.rating}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star_half, color: Colors.amber, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${product.reviews} ratings', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                children: [
                  _buildRatingBar(5, 0.8),
                  _buildRatingBar(4, 0.15),
                  _buildRatingBar(3, 0.03),
                  _buildRatingBar(2, 0.01),
                  _buildRatingBar(1, 0.01),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingBar(int star, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$star', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.black.withValues(alpha: 0.05),
                color: Colors.green,
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQASection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Questions & Answers', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Q: Is this product waterproof?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('A: Yes, it has an IPX7 rating for water resistance.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const Divider(height: 24),
              const Text('Q: Does it come with a warranty?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('A: Yes, it includes a 1-year manufacturer warranty.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: Colors.black12),
                ),
                child: const Text('ASK A QUESTION', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
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
              SizedBox(width: 4),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const Icon(Icons.group_outlined, color: AppColors.brandRed, size: 32),
          const SizedBox(height: 12),
          const Text('Share the Energy', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text(
            'Refer a friend and both of you earn ₹15 in ShopVerse credits when they complete their first purchase.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'SHARE TO EARN',
            onPressed: () {},
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
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to cart! 🛒'),
                  duration: Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(isInCart ? Icons.check : Icons.shopping_bag_outlined, color: isInCart ? Colors.green : AppColors.textPrimary),
                const SizedBox(width: 8),
                Text(
                  isInCart ? 'IN CART' : 'ADD TO CART',
                  style: TextStyle(color: isInCart ? Colors.green : AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 12),
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
      child: CustomButton(
        text: 'BUY NOW',
        onPressed: () {},
      ),
    );
  }
}
