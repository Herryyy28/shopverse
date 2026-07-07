import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopverse/utils/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Set<String> _selectedInterests = {};

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.shopping_bag_rounded,
      gradient: [Color(0xFF5B61F4), Color(0xFF7C3AED)],
      title: 'Welcome to ShopVerse',
      subtitle: 'Your AI-powered shopping universe with 10-minute delivery, AR try-ons, and exclusive deals.',
      emoji: '🛍️',
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome,
      gradient: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      title: 'AI-Powered Shopping',
      subtitle: 'Get personalized recommendations, voice search, and smart price tracking powered by AI.',
      emoji: '🤖',
    ),
    _OnboardingPage(
      icon: Icons.view_in_ar,
      gradient: [Color(0xFF00B4D8), Color(0xFF0077B6)],
      title: 'Try Before You Buy',
      subtitle: 'Use AR to visualize products in your space, try on clothes virtually, and see 360° views.',
      emoji: '✨',
    ),
    _OnboardingPage(
      icon: Icons.card_giftcard,
      gradient: [Color(0xFF2ECC71), Color(0xFF27AE60)],
      title: 'Win Rewards Daily',
      subtitle: 'Spin the wheel, scratch cards, mystery boxes, and earn coins on every purchase!',
      emoji: '🎁',
    ),
  ];

  final List<String> _interests = [
    '👟 Footwear', '📱 Electronics', '🥦 Grocery', '👗 Fashion',
    '🏠 Home & Living', '💄 Beauty', '🎮 Gaming', '📚 Books',
    '🍼 Baby & Kids', '🏋️ Fitness', '🐾 Pet Supplies', '🎨 Art & Craft',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setStringList('user_interests', _selectedInterests.toList());
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length;
    final isInterestPage = _currentPage == _pages.length;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length + 1, // +1 for interest selection
            onPageChanged: (index) => setState(() => _currentPage = index),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (index < _pages.length) {
                return _buildPage(_pages[index], index);
              }
              return _buildInterestPage();
            },
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                isLastPage ? '' : 'Skip',
                style: TextStyle(
                  color: _currentPage < _pages.length 
                    ? Colors.white70 
                    : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          // Bottom section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24, 20, 24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length + 1, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                            ? (_currentPage < _pages.length ? Colors.white : AppColors.primary)
                            : (_currentPage < _pages.length ? Colors.white38 : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLastPage) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInterestPage ? AppColors.primary : Colors.white,
                        foregroundColor: isInterestPage ? Colors.white : AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastPage ? 'Get Started 🚀' : 'Next',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          if (!isLastPage) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: page.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Animated icon with glow
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 800 + (index * 200)),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      page.emoji,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestPage() {
    return Container(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'What are you\ninterested in?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select categories to personalize your feed',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: _interests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedInterests.remove(interest);
                            } else {
                              _selectedInterests.add(interest);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey[300]!,
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                              ? [BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )]
                              : [],
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String emoji;

  const _OnboardingPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });
}
