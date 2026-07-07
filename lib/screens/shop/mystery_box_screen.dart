import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:shopverse/providers/wallet_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class MysteryBoxScreen extends StatefulWidget {
  const MysteryBoxScreen({super.key});

  @override
  State<MysteryBoxScreen> createState() => _MysteryBoxScreenState();
}

class _MysteryBoxScreenState extends State<MysteryBoxScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late ConfettiController _confettiController;

  bool _isOpening = false;
  bool _opened = false;
  String _rewardText = '';
  IconData _rewardIcon = Icons.card_membership;
  Color _rewardColor = Colors.orangeAccent;

  final List<Map<String, dynamic>> _rewardsList = [
    {'name': '100 ShopVerse Coins!', 'icon': Icons.stars, 'color': Colors.amber, 'coins': 100},
    {'name': '50% Discount Coupon: MYSTERY50', 'icon': Icons.card_giftcard, 'color': Colors.redAccent, 'coins': 0},
    {'name': 'Free Delivery on 5 Orders', 'icon': Icons.bolt, 'color': Colors.greenAccent[400]!, 'coins': 0},
    {'name': '200 ShopVerse Coins! (SUPER WIN)', 'icon': Icons.stars, 'color': Colors.amber, 'coins': 200},
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _openBox() async {
    if (_isOpening || _opened) return;

    setState(() {
      _isOpening = true;
      _opened = false;
    });

    // Loop the shake animation 4 times
    await _shakeController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 2));
    _shakeController.stop();

    final random = Random();
    final reward = _rewardsList[random.nextInt(_rewardsList.length)];
    
    if (!mounted) return;
    
    // Add coins if won
    if (reward['coins'] > 0) {
      Provider.of<WalletProvider>(context, listen: false).addCoins(reward['coins'] as int, 'Mystery Box Reward');
    }

    setState(() {
      _rewardText = reward['name'];
      _rewardIcon = reward['icon'] as IconData;
      _rewardColor = reward['color'] as Color;
      _isOpening = false;
      _opened = true;
    });

    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Mystery Box Store', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'UNBOX LUCKY REWARDS',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Purchase a lucky box to unlock exclusive coins, vouchers, or vouchers!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 48),

                  // Shaking Mystery Box Image
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      double offset = 0;
                      if (_shakeController.isAnimating) {
                        // Create a shaking translation offset
                        offset = sin(_shakeController.value * pi * 10) * 12;
                      }
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: _openBox,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 30,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: Icon(
                          _opened ? Icons.drafts_rounded : Icons.markunread_mailbox,
                          size: 150,
                          color: _opened ? _rewardColor : Colors.amber[700]!,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Reward Details Card
                  if (_opened) ...[
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _rewardColor.withValues(alpha: 0.3), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: _rewardColor.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _rewardColor.withValues(alpha: 0.1),
                                    radius: 30,
                                    child: Icon(_rewardIcon, color: _rewardColor, size: 30),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'UNLOCKED ITEM!',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _rewardText,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],

                  if (_isOpening) ...[
                    const CircularProgressIndicator(color: AppColors.brandRed),
                    const SizedBox(height: 16),
                    const Text(
                      'Unlocking mystery rewards...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ] else ...[
                    SizedBox(
                      width: 250,
                      child: CustomButton(
                        text: _opened ? 'OPEN ANOTHER BOX' : 'OPEN BOX (FREE)',
                        onPressed: () {
                          if (_opened) {
                            setState(() {
                              _opened = false;
                              _rewardText = '';
                            });
                          } else {
                            _openBox();
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Confetti particle overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.amber, Colors.orange, Colors.red, Colors.green, Colors.blue],
            ),
          ),
        ],
      ),
    );
  }
}
