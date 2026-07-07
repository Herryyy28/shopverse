import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/wishlist_provider.dart';
import 'package:shopverse/providers/location_provider.dart';
import 'package:shopverse/providers/recent_provider.dart';
import 'package:shopverse/providers/wallet_provider.dart';
import 'package:shopverse/screens/shop/search_screen.dart';
import 'package:shopverse/screens/shop/product_details_screen.dart';
import 'package:shopverse/services/ai_service.dart';
import 'package:shopverse/services/firebase_service.dart';
import 'package:shopverse/providers/product_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';
import 'package:shopverse/widgets/custom_text_field.dart';
import 'package:shopverse/widgets/spin_wheel_dialog.dart';
import 'package:shopverse/widgets/delivery_eta_banner.dart';
import 'package:shopverse/widgets/flash_deal_radar.dart';
import 'package:shopverse/widgets/autopilot_restock_widget.dart';
import 'package:shopverse/screens/shop/balloon_pop_screen.dart';
import 'package:shopverse/screens/shop/shoppable_feed_screen.dart';
import 'package:shopverse/widgets/mystery_deal_spinner.dart';
import 'package:shopverse/screens/shop/virtual_tryon_screen.dart';
import 'package:shopverse/screens/shop/variant_designer_screen.dart';
import 'package:shopverse/screens/shop/spatial_room_screen.dart';
import 'package:shopverse/screens/shop/shared_cart_screen.dart';
import 'package:shopverse/screens/shop/recipe_builder_screen.dart';
import 'package:shopverse/screens/profile/pantry_tracker_screen.dart';
import 'package:shopverse/screens/shop/smart_list_screen.dart';

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
    _flashSaleSubscription = FirebaseService.getFlashSaleEndTime().listen((
      endTime,
    ) {
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAIChat(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.auto_awesome, color: Colors.amber),
        label: const Text(
          'Ask ShopVerse AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Product>>(
          stream: productProv.productsStream,
          builder: (context, snapshot) {
            final allProducts = snapshot.data ?? productProv.products;

            if (snapshot.connectionState == ConnectionState.waiting &&
                allProducts.isEmpty) {
              return _buildShimmerLoading();
            }

            final recommended = AIService.getRecommendations(allProducts);
            final newlyAdded = allProducts.reversed.take(5).toList();

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.white,
              strokeWidth: 3,
              displacement: 60,
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 1500));
                if (mounted) {
                  productProv.refreshProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feed refreshed! ✨'),
                      duration: Duration(milliseconds: 800),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  _buildBlinkitHeader(context),
                  _buildStickySearch(context),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildDailyCoinsAndSpinBanner(context),
                        const DeliveryEtaBanner(),
                        _buildSmartListBanner(context),
                        const FlashDealRadar(),
                        const AutopilotRestockWidget(),
                        _buildAIHub(context),
                        _buildBalloonPopLauncher(context),
                        _buildShoppableFeedLauncher(context),
                        _buildMysterySpinnerLauncher(context),
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
                            if (recentProv.recentlyViewed.isEmpty)
                              return const SizedBox.shrink();
                            return Column(
                              children: [
                                _buildSectionHeader(
                                  'Recently Viewed',
                                  'Pick up where you left off',
                                ),
                                _buildHorizontalList(
                                  context,
                                  recentProv.recentlyViewed,
                                ),
                              ],
                            );
                          },
                        ),

                        _buildSectionHeader(
                          'Recommended for You',
                          'Picked by ShopVerse AI',
                          isAI: true,
                        ),
                        _buildHorizontalRecommendations(context, recommended),

                        _buildSectionHeader(
                          'Daily Deals',
                          'Exclusive offers just for you',
                        ),
                        _buildDailyDealsGrid(
                          context,
                          allProducts.take(4).toList(),
                        ),

                        _buildSectionHeader('Bestsellers', 'Trending items'),
                        _buildHorizontalList(context, allProducts),
                        _buildSectionHeader('Daily Staples', 'Fresh & Essential'),
                        _buildVerticalGrid(context, allProducts),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 120, color: Colors.white),
            const SizedBox(height: 20),
            Container(
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: 8,
                itemBuilder: (_, _) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: Container(height: 20, color: Colors.white)),
                  const SizedBox(width: 100),
                  Container(width: 40, height: 16, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 3,
                itemBuilder: (_, _) => Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAIChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ShopVerse AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Your personal shopping assistant',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildAiChatBubble(
                      'Hi there! 👋 I am your ShopVerse AI assistant. What are you looking for today?',
                      false,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildAiSuggestionChip(
                          'Find me a smartwatch under ₹2000',
                        ),
                        _buildAiSuggestionChip('Best products for oily skin'),
                        _buildAiSuggestionChip('Healthy snacks for diet'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: isUser ? 40 : 0, right: isUser ? 0 : 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          border: isUser
              ? null
              : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildAiSuggestionChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle, {
    bool isAI = false,
  }) {
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
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'See all',
            style: TextStyle(
              color: AppColors.brandRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalRecommendations(
    BuildContext context,
    List<Product> recommendations,
  ) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: recommendations.length,
        itemBuilder: (context, i) =>
            _AiProductCard(product: recommendations[i]),
      ),
    );
  }

  Widget _buildBlinkitHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<LocationProvider>(
        builder: (context, locationProvider, _) {
          final address = locationProvider.selectedAddress;
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B61F4), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _showLocationPicker(context, locationProvider),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
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
                              'Deliver to ${address.label}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ],
                        ),
                        Text(
                          '${address.addressLine}, ${address.area}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
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
                    onTap: provider.isFetchingLocation
                        ? null
                        : () async {
                            await provider.fetchCurrentLocation();
                            if (context.mounted) {
                              Future.microtask(() {
                                if (context.mounted) Navigator.pop(context);
                              });
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.brandRed.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: AppColors.brandRed,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Use current location',
                                  style: TextStyle(
                                    color: AppColors.brandRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  provider.isFetchingLocation
                                      ? 'Detecting...'
                                      : 'Using GPS to find your address',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (provider.isFetchingLocation)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.brandRed,
                              ),
                            ),
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
                          child: Text(
                            'SAVED ADDRESSES',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      itemCount: provider.addresses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final address = provider.addresses[index];
                        final isSelected =
                            provider.selectedAddress.id == address.id;

                        return InkWell(
                          onTap: () {
                            provider.selectAddress(index);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.brandRed.withValues(alpha: 0.02)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.brandRed
                                    : Colors.grey.withValues(alpha: 0.2),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected
                                      ? AppColors.brandRed
                                      : Colors.grey[100],
                                  child: Icon(
                                    address.label == 'Home'
                                        ? Icons.home
                                        : (address.label == 'Work'
                                              ? Icons.work
                                              : Icons.location_on),
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address.label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: isSelected
                                              ? AppColors.brandRed
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${address.addressLine}, ${address.area}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.brandRed,
                                  ),
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
        title: const Text(
          'Add New Address',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: labelController,
              label: 'Label (e.g. Other, Gym)',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: addressController,
              label: 'Address Line',
            ),
            const SizedBox(height: 12),
            CustomTextField(controller: areaController, label: 'Area/Sector'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 100,
            child: CustomButton(
              text: 'SAVE',
              onPressed: () {
                if (labelController.text.isNotEmpty &&
                    addressController.text.isNotEmpty) {
                  provider.addAddress(
                    labelController.text,
                    addressController.text,
                    areaController.text,
                  );
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

  Widget _buildDailyCoinsAndSpinBanner(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ShopVerse Coins: ${wallet.coinsBalance}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  wallet.hasSpunToday
                      ? 'You spun today! Come back tomorrow.'
                      : 'Spin the Daily Wheel to win coins!',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: wallet.hasSpunToday
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (context) => const SpinWheelDialog(),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              wallet.hasSpunToday ? 'SPUN' : 'SPIN',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalloonPopLauncher(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.videogame_asset_outlined,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balloon Pop Arcade Game',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Pop balloons in 10s to win coins!',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BalloonPopScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.pink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'PLAY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppableFeedLauncher(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.video_library_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Unboxings Feed',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Watch short videos & buy instantly!',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShoppableFeedScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'WATCH',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMysterySpinnerLauncher(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mystery Box Spinner Deal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Spin to win random high-discount deals!',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const MysteryDealSpinner(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'SPIN',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionBanner() {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: PageView(
        children: [
          _promoCard(
            'GET 50% OFF',
            'On your first 3 orders',
            'USE CODE: SHOP50',
            Colors.orange,
          ),
          _promoCard(
            'FRESH FRUITS',
            'Organic & Handpicked',
            'SHOP NOW',
            Colors.green,
          ),
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
          image: NetworkImage(
            'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
          ),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
          opacity: 0.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
          Text(sub, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'n': 'Grocery', 'i': Icons.eco, 'c': const Color(0xFF10B981)},
      {'n': 'Dairy', 'i': Icons.water_drop, 'c': const Color(0xFF3B82F6)},
      {'n': 'Snacks', 'i': Icons.fastfood, 'c': const Color(0xFFF59E0B)},
      {'n': 'Drinks', 'i': Icons.local_drink, 'c': const Color(0xFF06B6D4)},
      {'n': 'Beauty', 'i': Icons.face, 'c': const Color(0xFFEC4899)},
      {'n': 'Home', 'i': Icons.home, 'c': const Color(0xFF8B5CF6)},
      {'n': 'Pharma', 'i': Icons.medication, 'c': const Color(0xFFEF4444)},
      {'n': 'More', 'i': Icons.grid_view, 'c': const Color(0xFF6B7280)},
    ];

    final width = MediaQuery.of(context).size.width;
    final cols = width > 900 ? 8 : (width > 600 ? 6 : 4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: width > 600 ? 1.1 : 0.85,
        ),
        itemCount: categories.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SearchScreen(initialQuery: categories[i]['n'] as String),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (categories[i]['c'] as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  categories[i]['i'] as IconData,
                  color: categories[i]['c'] as Color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                categories[i]['n'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
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
    final width = MediaQuery.of(context).size.width;
    final cols = width > 900 ? 4 : (width > 600 ? 3 : 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          childAspectRatio: width > 900 ? 1.8 : 1.5,
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
                          [
                            Colors.blue,
                            Colors.purple,
                            Colors.orange,
                            Colors.teal,
                          ][i % 4].withValues(alpha: 0.1),
                          [
                            Colors.blue,
                            Colors.purple,
                            Colors.orange,
                            Colors.teal,
                          ][i % 4].withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(
                        color: [
                          Colors.blue,
                          Colors.purple,
                          Colors.orange,
                          Colors.teal,
                        ][i % 4].withValues(alpha: 0.2),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: Opacity(
                            opacity: 0.5,
                            child: CachedNetworkImage(
                              imageUrl: deals[i].imageUrl,
                              width: 80,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deals[i].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Flat ₹${(deals[i].oldPrice - deals[i].price).toInt()} OFF',
                                style: TextStyle(
                                  color: [
                                    Colors.blue,
                                    Colors.purple,
                                    Colors.orange,
                                    Colors.teal,
                                  ][i % 4],
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'GRAB NOW',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
    final width = MediaQuery.of(context).size.width;
    final cols = width > 900 ? 5 : (width > 600 ? 3 : 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flash Sale Ending In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TimerBox(value: _formatDuration(_timeLeft.inHours)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _TimerBox(value: _formatDuration(_timeLeft.inMinutes % 60)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
              style: TextStyle(
                color: Color(0xFFFF416C),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartListBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.playlist_add_check_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Shopping List Importer',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Paste or record a list to add all items at once!',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartListScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('IMPORT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAIHub(BuildContext context) {
    final tools = [
      {
        'title': 'Smart List Importer',
        'sub': 'Import text/voice list',
        'icon': Icons.playlist_add_check_rounded,
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFFD946EF)],
        'screen': const SmartListScreen(),
      },
      {
        'title': 'AI Virtual Fit Try-On',
        'sub': 'Try clothes on avatar',
        'icon': Icons.face_retouching_natural,
        'gradient': [const Color(0xFFFF5722), const Color(0xFFFF9800)],
        'screen': const VirtualTryonScreen(),
      },
      {
        'title': 'Sneaker Designer',
        'sub': 'Customize variant style',
        'icon': Icons.palette_outlined,
        'gradient': [const Color(0xFF2196F3), const Color(0xFF00BCD4)],
        'screen': const VariantDesignerScreen(),
      },
      {
        'title': 'Spatial Room AR',
        'sub': 'Furnish space in 3D',
        'icon': Icons.door_sliding_outlined,
        'gradient': [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
        'screen': const SpatialRoomScreen(),
      },
      {
        'title': 'Group Cart Splitter',
        'sub': 'Shop together with friends',
        'icon': Icons.group_work_outlined,
        'gradient': [const Color(0xFFE91E63), const Color(0xFF9C27B0)],
        'screen': const SharedCartScreen(),
      },
      {
        'title': 'Recipe-to-Cart',
        'sub': 'Order complete recipes',
        'icon': Icons.soup_kitchen_outlined,
        'gradient': [const Color(0xFF795548), const Color(0xFFFF9800)],
        'screen': const RecipeBuilderScreen(),
      },
      {
        'title': 'Smart Shelf Pantry',
        'sub': 'Track home essentials',
        'icon': Icons.kitchen_outlined,
        'gradient': [const Color(0xFF607D8B), const Color(0xFF9E9E9E)],
        'screen': const PantryTrackerScreen(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('AI Assistants & Tools Hub', 'Interactive smart shopping assistants', isAI: true),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => tool['screen'] as Widget),
                  );
                },
                child: Container(
                  width: 170,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: tool['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (tool['gradient'] as List<Color>).first.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(tool['icon'] as IconData, color: Colors.white, size: 22),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 14),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        tool['title'] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        tool['sub'] as String,
                        style: const TextStyle(color: Colors.white70, fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        ),
      ),
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
            ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B61F4), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Text(
                'Search products, brands, categories...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              Spacer(),
              Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 20),
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
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        ),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      color: const Color(0xFFF6F7FB),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            placeholder: (c, u) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            errorWidget: (c, u, e) => const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey,
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (product.discount > 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${product.discount}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlist, _) => GestureDetector(
                        onTap: () => wishlist.toggleWishlist(product),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            wishlist.isFavorite(product.id)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: wishlist.isFavorite(product.id)
                                ? Colors.red
                                : Colors.grey[400],
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
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.unit,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${product.price.toInt()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (product.oldPrice > product.price)
                            Text(
                              '₹${product.oldPrice.toInt()}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
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
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'ADD',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
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
