import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final String _referralCode = "SV-HERRY-7829";

  final List<Map<String, dynamic>> _milestones = [
    {
      'friends': 1,
      'reward': '₹100 Wallet Balance',
      'unlocked': true,
      'claimed': true,
    },
    {
      'friends': 3,
      'reward': '200 ShopVerse Coins',
      'unlocked': true,
      'claimed': false,
    },
    {
      'friends': 5,
      'reward': 'Free Delivery on 10 Orders',
      'unlocked': false,
      'claimed': false,
    }
  ];

  void _claimReward(int index) {
    setState(() {
      _milestones[index]['claimed'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Claimed reward: ${_milestones[index]['reward']}!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Refer & Earn', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Highlight banner
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.group_add_rounded, size: 72, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'Invite Friends, Get Rewards!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your invite code with friends. When they register, you both get premium rewards!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Code Display Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR REFERRAL CODE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _referralCode,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.primary),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'COPY INVITE LINK',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Referral link copied to clipboard!'),
                                  backgroundColor: Colors.blue,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              const Text(
                'Referral Milestones',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),

              // Milestones list
              ..._milestones.asMap().entries.map((entry) {
                final index = entry.key;
                final milestone = entry.value;
                final bool unlocked = milestone['unlocked'] as bool;
                final bool claimed = milestone['claimed'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: unlocked ? Colors.green.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: unlocked ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                        radius: 20,
                        child: Icon(
                          unlocked ? Icons.check : Icons.lock_outline,
                          color: unlocked ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Refer ${milestone['friends']} ${milestone['friends'] == 1 ? "Friend" : "Friends"}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              milestone['reward'] as String,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      
                      // Action state button
                      if (unlocked && !claimed)
                        ElevatedButton(
                          onPressed: () => _claimReward(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('CLAIM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      else if (claimed)
                        const Text(
                          'CLAIMED',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                        )
                      else
                        const Text(
                          'LOCKED',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
