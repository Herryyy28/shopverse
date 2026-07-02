import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometrics = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('APP PREFERENCES', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 12),
              
              // Dark Mode switcher
              _buildSettingCard(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Theme Mode',
                subtitle: 'Enable premium dark aesthetics',
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) {
                    // Toggle local app brightness mode settings (mocked or theme notifier integration)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Theme switched!'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Push notifications options
              _buildSettingCard(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: 'Alerts on deals and pantry expiry',
                trailing: Switch(
                  value: _notifications,
                  onChanged: (val) {
                    setState(() {
                      _notifications = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              const Text('SECURITY', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 12),

              // Biometric Auth lock toggle
              _buildSettingCard(
                icon: Icons.fingerprint_outlined,
                title: 'Biometric Face ID Lock',
                subtitle: 'Secure wallet checkouts with biometric locks',
                trailing: Switch(
                  value: _biometrics,
                  onChanged: (val) {
                    setState(() {
                      _biometrics = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              const Text('ACCOUNT & HELP', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 12),

              // Account info details
              _buildSettingCard(
                icon: Icons.info_outline,
                title: 'About ShopVerse',
                subtitle: 'Version 2.4.0 (Build 7829)',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Go to logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    authProv.logout();
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('LOG OUT ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
