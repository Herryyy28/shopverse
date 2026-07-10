import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/auth_provider.dart';
import 'package:shopverse/providers/theme_provider.dart';
import 'package:shopverse/screens/profile/orders_screen.dart';
import 'package:shopverse/screens/profile/notifications_screen.dart';
import 'package:shopverse/screens/profile/edit_profile_screen.dart';
import 'package:shopverse/screens/profile/wallet_screen.dart';
import 'package:shopverse/screens/admin/admin_dashboard.dart';
import 'package:shopverse/screens/core/chat_screen.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/utils/app_spacing.dart';
import 'package:shopverse/widgets/custom_button.dart';
import 'package:shopverse/widgets/scratch_card_dialog.dart';
import 'package:shopverse/screens/shop/mystery_box_screen.dart';
import 'package:shopverse/screens/shop/video_feed_screen.dart';
import 'package:shopverse/screens/shop/shared_cart_screen.dart';
import 'package:shopverse/screens/shop/virtual_tryon_screen.dart';
import 'package:shopverse/screens/shop/spatial_room_screen.dart';
import 'package:shopverse/screens/shop/recipe_builder_screen.dart';
import 'package:shopverse/screens/profile/login_streak_screen.dart';
import 'package:shopverse/screens/profile/referral_screen.dart';
import 'package:shopverse/screens/profile/avatar_preview_screen.dart';
import 'package:shopverse/screens/shop/group_registry_screen.dart';
import 'package:shopverse/screens/profile/pantry_tracker_screen.dart';
import 'package:shopverse/screens/shop/variant_designer_screen.dart';
import 'package:shopverse/screens/profile/eco_impact_screen.dart';
import 'package:shopverse/screens/profile/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!authProvider.isAuthenticated || user == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_off_outlined, size: 56, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                const Text('Session Expired', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(
                  'Please login again to access your profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 32),
                CustomButton(text: 'Go to Login', onPressed: () => authProvider.logout()),
              ],
            ),
          ),
        ),
      );
    }

    final isAdmin = user.role == 'admin';
    final isSeller = user.role == 'vendor' || user.role == 'seller';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient Hero Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                ),
                Positioned(
                  top: 52,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      _HeaderAction(
                        icon: Icons.settings_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile card overlapping the gradient
                Positioned(
                  bottom: -72,
                  left: 16,
                  right: 16,
                  child: _ProfileHeaderCard(
                    user: user,
                    isAdmin: isAdmin,
                    isSeller: isSeller,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          // ── Spacer for the overlapping card ──────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 88)),

          // ── Stats row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: [
                  _StatBox(
                    label: 'Orders',
                    value: '12',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    ),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'Wishlist',
                    value: '5',
                    icon: Icons.favorite_border_rounded,
                    color: AppColors.brandRed,
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'Wallet',
                    value: '₹500',
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.accentGreen,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletScreen()),
                    ),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Account Section ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionCard(
              label: 'ACCOUNT',
              isDark: isDark,
              children: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  iconBg: AppColors.primaryLight,
                  iconColor: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  ),
                ),
                _ThemeToggleItem(),
                _MenuItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  iconBg: AppColors.warningLight,
                  iconColor: AppColors.warning,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.support_agent_rounded,
                  label: 'Help & Support',
                  iconBg: AppColors.infoLight,
                  iconColor: AppColors.info,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatScreen(
                        receiverId: 'admin',
                        receiverName: 'ShopVerse Support',
                      ),
                    ),
                  ),
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About ShopVerse',
                  iconBg: AppColors.surface2,
                  iconColor: AppColors.textSecondary,
                  onTap: () {},
                  isLast: true,
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Rewards & Gaming Section ──────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionCard(
              label: 'REWARDS & GAMING',
              isDark: isDark,
              children: [
                _MenuItem(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Daily Check-in Streak',
                  iconBg: const Color(0xFFFFECE0),
                  iconColor: Colors.deepOrange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginStreakScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.share_rounded,
                  label: 'Referral Rewards',
                  iconBg: AppColors.primaryLight,
                  iconColor: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReferralScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.card_giftcard_rounded,
                  label: 'Lucky Scratch Coupon',
                  iconBg: AppColors.accentGreenLight,
                  iconColor: AppColors.accentGreen,
                  onTap: () => showDialog(context: context, builder: (_) => const ScratchCardDialog()),
                ),
                _MenuItem(
                  icon: Icons.all_inclusive_rounded,
                  label: 'Mystery Reward Box',
                  iconBg: const Color(0xFFF3E5F5),
                  iconColor: Colors.deepPurple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MysteryBoxScreen()),
                  ),
                  isLast: true,
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── AI Studio Section ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionCard(
              label: 'AI FIT & STUDIO',
              isDark: isDark,
              children: [
                _MenuItem(
                  icon: Icons.face_retouching_natural_rounded,
                  label: 'AI Virtual Fit Try-On',
                  iconBg: const Color(0xFFFCE4EC),
                  iconColor: Colors.pinkAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VirtualTryonScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.face_unlock_outlined,
                  label: 'My Avatar Closet',
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AvatarPreviewScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.palette_outlined,
                  label: 'Custom Sneaker Designer',
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VariantDesignerScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.door_sliding_outlined,
                  label: 'Spatial Room AR Furnish',
                  iconBg: AppColors.blinkitYellowLight,
                  iconColor: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SpatialRoomScreen()),
                  ),
                  isLast: true,
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Social Shopping Section ───────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionCard(
              label: 'SOCIAL & SMART SHOPPING',
              isDark: isDark,
              children: [
                _MenuItem(
                  icon: Icons.group_work_outlined,
                  label: 'Group Cart Splitter',
                  iconBg: AppColors.primaryLight,
                  iconColor: AppColors.primary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SharedCartScreen())),
                ),
                _MenuItem(
                  icon: Icons.card_membership_outlined,
                  label: 'My Gift Registries',
                  iconBg: const Color(0xFFFCE4EC),
                  iconColor: Colors.pinkAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupRegistryScreen())),
                ),
                _MenuItem(
                  icon: Icons.kitchen_outlined,
                  label: 'Smart Shelf Pantry',
                  iconBg: AppColors.accentGreenLight,
                  iconColor: AppColors.accentGreen,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryTrackerScreen())),
                ),
                _MenuItem(
                  icon: Icons.soup_kitchen_outlined,
                  label: 'Recipe Ingredients Cart',
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeBuilderScreen())),
                ),
                _MenuItem(
                  icon: Icons.eco_outlined,
                  label: 'My Eco-Impact Dashboard',
                  iconBg: AppColors.accentGreenLight,
                  iconColor: AppColors.accentGreen,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EcoImpactScreen())),
                ),
                _MenuItem(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Video Commerce Feed',
                  iconBg: const Color(0xFFFCE4EC),
                  iconColor: Colors.redAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoFeedScreen())),
                  isLast: true,
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Admin / Seller Panel ──────────────────────────────────────────
          if (isAdmin || isSeller)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _RoleDashboardCard(
                  isAdmin: isAdmin,
                  vendorId: user.uid,
                  isDark: isDark,
                ),
              ),
            ),

          if (isAdmin || isSeller)
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Logout ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => _showLogoutDialog(context, authProvider),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A1A1A) : AppColors.brandRedLight,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(Icons.logout_rounded, color: AppColors.brandRed, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            color: AppColors.brandRed,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.brandRed, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.brandRed),
            SizedBox(width: 10),
            Text('Log Out?', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Sub-Widgets ────────────────────────────────────────────────────────────────

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final dynamic user;
  final bool isAdmin, isSeller, isDark;
  const _ProfileHeaderCard({
    required this.user,
    required this.isAdmin,
    required this.isSeller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final String roleLabel = isAdmin ? 'Admin' : (isSeller ? 'Seller' : 'Gold Member');
    final Color roleBg = isAdmin ? AppColors.blinkitYellowLight : (isSeller ? AppColors.infoLight : AppColors.accentGreenLight);
    final Color roleColor = isAdmin ? Colors.orange[800]! : (isSeller ? AppColors.info : AppColors.accentGreen);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundImage: NetworkImage(
                    user.profileImageUrl ?? 'https://ui-avatars.com/api/?name=${user.name}&background=5B61F4&color=fff',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    roleLabel,
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: roleColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        isAdmin ? 'Store Manager' : (isSeller ? 'Verified Seller' : 'Gold Member'),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadow.sm,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String label;
  final List<Widget> children;
  final bool isDark;
  const _SectionCard({required this.label, required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadow.sm,
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg, iconColor;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(0),
              bottom: isLast ? const Radius.circular(AppRadius.xl) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 56,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
      ],
    );
  }
}

class _ThemeToggleItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Switch(
                value: isDark,
                onChanged: (v) => themeProvider.toggleTheme(v),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          indent: 56,
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.border,
        ),
      ],
    );
  }
}

class _RoleDashboardCard extends StatelessWidget {
  final bool isAdmin, isDark;
  final String vendorId;
  const _RoleDashboardCard({required this.isAdmin, required this.isDark, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final gradient = isAdmin
        ? const LinearGradient(colors: [Color(0xFFFF8C00), Color(0xFFFF4500)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF6366F1)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    final label = isAdmin ? 'Admin Dashboard' : 'Seller Dashboard';
    final sub = isAdmin ? 'Manage store, users & analytics' : 'Manage listings, orders & sales';
    final icon = isAdmin ? Icons.admin_panel_settings_rounded : Icons.storefront_rounded;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => isAdmin ? const AdminDashboard() : AdminDashboard(vendorId: vendorId)),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: (isAdmin ? Colors.orange : AppColors.primary).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
