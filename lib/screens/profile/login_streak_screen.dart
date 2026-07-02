import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/wallet_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class LoginStreakScreen extends StatefulWidget {
  const LoginStreakScreen({super.key});

  @override
  State<LoginStreakScreen> createState() => _LoginStreakScreenState();
}

class _LoginStreakScreenState extends State<LoginStreakScreen> {
  int _currentStreak = 3;
  bool _checkedInToday = false;

  final List<Map<String, dynamic>> _streakDays = [
    {'day': 1, 'reward': 10, 'label': 'Day 1'},
    {'day': 2, 'reward': 10, 'label': 'Day 2'},
    {'day': 3, 'reward': 15, 'label': 'Day 3'},
    {'day': 4, 'reward': 20, 'label': 'Day 4'},
    {'day': 5, 'reward': 25, 'label': 'Day 5'},
    {'day': 6, 'reward': 30, 'label': 'Day 6'},
    {'day': 7, 'reward': 100, 'label': 'MEGA BOX', 'isSpecial': true},
  ];

  void _checkIn() {
    if (_checkedInToday) return;

    final wallet = Provider.of<WalletProvider>(context, listen: false);
    final todayReward = _streakDays[_currentStreak]['reward'] as int;

    wallet.addCoins(todayReward, 'Daily Check-in Day ${_currentStreak + 1}');

    setState(() {
      _currentStreak++;
      _checkedInToday = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Day $_currentStreak Check-in successful! +$todayReward Coins added.'),
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
        title: const Text('Daily Check-in Streak', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Calendar Banner card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CURRENT STREAK', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      '$_currentStreak Days Checked-in',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Check-in 7 days consecutively to claim a Mega Mystery Reward Box!',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Streak Progress Calendar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 16),

              // Streak Grid mapping days 1-7
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _streakDays.length,
                itemBuilder: (context, index) {
                  final dayData = _streakDays[index];
                  final int dayIndex = dayData['day'] as int;
                  final isSpecial = dayData['isSpecial'] == true;

                  // Determine state
                  final bool isPassed = dayIndex <= _currentStreak;
                  final bool isActive = dayIndex == _currentStreak + 1 && !_checkedInToday;

                  Color cardBg = isDark ? const Color(0xFF1E1E2F) : Colors.white;
                  Color borderCol = Colors.black.withValues(alpha: 0.05);

                  if (isPassed) {
                    cardBg = Colors.green.withValues(alpha: 0.1);
                    borderCol = Colors.green.withValues(alpha: 0.3);
                  } else if (isActive) {
                    cardBg = AppColors.primaryLight;
                    borderCol = AppColors.primary;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol, width: isActive ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayData['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? Colors.green : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Icon(
                          isPassed
                              ? Icons.check_circle
                              : isSpecial
                                  ? Icons.redeem
                                  : Icons.stars,
                          color: isPassed
                              ? Colors.green
                              : isSpecial
                                  ? Colors.orangeAccent
                                  : Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+${dayData['reward']} coins',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: isPassed ? Colors.green : Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _checkedInToday ? 'CHECKED-IN FOR TODAY' : 'CHECK-IN NOW',
                  onPressed: _checkedInToday ? null : _checkIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
