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
    
    if (!authProvider.isAuthenticated || user == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text("Session Expired", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text("Please login again to access your profile", style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                CustomButton(
                  text: "GO TO LOGIN",
                  onPressed: () => authProvider.logout(),
                )
              ],
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: const Icon(Icons.bolt, color: AppColors.brandRed),
        title: const Text('My Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Profile Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppColors.brandRed, Colors.orangeAccent]),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(user.profileImageUrl ?? 'https://ui-avatars.com/api/?name=${user.name}&background=random'),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(user.role == 'admin' ? 'ADMIN' : 'GOLD', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.stars, color: Colors.amber[700], size: 16),
                            const SizedBox(width: 4),
                            Text(user.role == 'admin' ? 'Store Manager' : 'Gold Member', 
                              style: TextStyle(color: Colors.amber[700], fontWeight: FontWeight.w900, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildWalletQuickView(context),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildQuickAction(Icons.inventory_2_outlined, 'Orders', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
                  const SizedBox(width: 12),
                  _buildQuickAction(Icons.location_on_outlined, 'Addresses', () {}),
                  const SizedBox(width: 12),
                  _buildQuickAction(Icons.payment_outlined, 'Payments', () {}),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor, 
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.person_outline, 'Edit Profile', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildThemeToggleItem(context),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.notifications_none_outlined, 'Notifications', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.help_outline, 'Help & Support', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatScreen(
                          receiverId: 'admin',
                          receiverName: 'ShopVerse Support',
                        ),
                      ),
                    );
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.info_outline, 'About ShopVerse', () {}),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Interactive Corner Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 20),
                  SizedBox(width: 8),
                  Text('Interactive Zone', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
            ),
             const SizedBox(height: 12),
            _buildProfileSectionHeader('INTERACTIVE GAMING & REWARDS'),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.calendar_month_outlined, 'Daily Check-in Streak', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginStreakScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.share_outlined, 'Referral Rewards Center', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.card_giftcard, 'Lucky Scratch Coupon', () {
                    showDialog(context: context, builder: (_) => const ScratchCardDialog());
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.markunread_mailbox_outlined, 'Mystery Reward Box', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MysteryBoxScreen()));
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildProfileSectionHeader('AI FIT & CUSTOMIZER STUDIO'),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.face_retouching_natural, 'AI Virtual Fit Try-On', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VirtualTryonScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.face_unlock_outlined, 'My Avatar Closet', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AvatarPreviewScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.palette_outlined, 'Custom Sneaker Designer', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VariantDesignerScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.door_sliding_outlined, 'Spatial Room AR Furnish', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SpatialRoomScreen()));
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildProfileSectionHeader('SMART HOUSEHOLD & SOCIAL SHOPPING'),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.group_work_outlined, 'Group Cart Splitter', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SharedCartScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.card_membership_outlined, 'My Gift Registries', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupRegistryScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.kitchen_outlined, 'Smart Shelf Pantry', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryTrackerScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.soup_kitchen_outlined, 'Recipe Ingredients Cart', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeBuilderScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.eco_outlined, 'My Eco-Impact Dashboard', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EcoImpactScreen()));
                  }),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.video_library_outlined, 'Video Commerce Feed', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoFeedScreen()));
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Admin Tile (Dynamic Visibility)
            if (user.role == 'admin') _buildAdminTile(context),

            const SizedBox(height: 16),

            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5), 
                borderRadius: BorderRadius.circular(24),
              ),
              child: _buildMenuItem(Icons.logout, 'Logout', () {
                _showLogoutDialog(context, authProvider);
              }, textColor: Colors.red),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to log out of your account?', style: TextStyle(color: AppColors.textSecondary)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary))),
          SizedBox(
            width: 120,
            child: CustomButton(
              text: 'LOGOUT',
              onPressed: () {
                Navigator.pop(ctx);
                auth.logout();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.brandRed),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? textColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (textColor ?? AppColors.textPrimary).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: textColor ?? AppColors.textPrimary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: textColor ?? AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Widget _buildAdminTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFF8E1),
          child: Icon(Icons.admin_panel_settings, color: Colors.amber),
        ),
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        subtitle: const Text('Manage store & view analytics', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard())),
      ),
    );
  }

  Widget _buildWalletQuickView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(Icons.account_balance_wallet, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ShopVerse Wallet', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                Text('Balance: ₹500.00', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 36,
            child: CustomButton(
              text: 'VIEW',
              backgroundColor: AppColors.brandRed.withValues(alpha: 0.1),
              foregroundColor: AppColors.brandRed,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleItem(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        activeThumbColor: AppColors.primary,
        onChanged: (value) => themeProvider.toggleTheme(value),
      ),
    );
  }
}
