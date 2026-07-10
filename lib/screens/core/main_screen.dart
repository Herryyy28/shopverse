import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/screens/shop/home_screen.dart';
import 'package:shopverse/screens/shop/search_screen.dart';
import 'package:shopverse/screens/shop/shoppable_feed_screen.dart';
import 'package:shopverse/screens/profile/profile_screen.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/cart_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _cartStripController;
  late Animation<double> _cartStripAnim;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ShoppableFeedScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _cartStripController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cartStripAnim = CurvedAnimation(
      parent: _cartStripController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _cartStripController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      endDrawer: const CartDrawer(),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero)
                      .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _screens[_selectedIndex],
            ),
          ),
          _buildFloatingCartStrip(context),
        ],
      ),
      bottomNavigationBar: _buildPremiumNavBar(isDark),
    );
  }

  Widget _buildPremiumNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 0.5,
          ),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.search_outlined, Icons.manage_search_rounded, 'Browse'),
              _buildNavItem(2, Icons.play_circle_outline_rounded, Icons.play_circle_fill_rounded, 'ShopTok'),
              _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.primaryLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 22,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCartStrip(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final hasItems = cart.itemCount > 0;

        if (hasItems) {
          _cartStripController.forward();
        } else {
          _cartStripController.reverse();
        }

        return Positioned(
          bottom: 80,
          left: 16,
          right: 16,
          child: ScaleTransition(
            scale: _cartStripAnim,
            child: FadeTransition(
              opacity: _cartStripAnim,
              child: hasItems
                  ? GestureDetector(
                      onTap: () => Scaffold.of(context).openEndDrawer(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: -2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                                  Positioned(
                                    top: -7,
                                    right: -7,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                      child: Container(
                                        key: ValueKey(cart.itemCount),
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${cart.itemCount}',
                                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${cart.itemCount} ${cart.itemCount == 1 ? "item" : "items"} in bag',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, anim) => SlideTransition(
                                      position: Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
                                          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                                      child: FadeTransition(opacity: anim, child: child),
                                    ),
                                    child: Text(
                                      '₹${cart.totalAmount.toInt()}',
                                      key: ValueKey(cart.totalAmount.toInt()),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Text('View Bag', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
