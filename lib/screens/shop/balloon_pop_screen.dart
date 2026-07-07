import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/wallet_provider.dart';

import 'package:shopverse/widgets/custom_button.dart';

class BalloonPopScreen extends StatefulWidget {
  const BalloonPopScreen({super.key});

  @override
  State<BalloonPopScreen> createState() => _BalloonPopScreenState();
}

class _BalloonPopScreenState extends State<BalloonPopScreen> with SingleTickerProviderStateMixin {
  late AnimationController _gameController;
  Timer? _timer;
  int _secondsLeft = 10;
  int _score = 0;
  bool _gameOver = false;
  final List<_Balloon> _balloons = [];

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _generateBalloons();
    _startGameTimer();
  }

  void _generateBalloons() {
    final rand = Random();
    for (int i = 0; i < 15; i++) {
      _balloons.add(_Balloon(
        id: i,
        leftPercent: 0.05 + rand.nextDouble() * 0.8,
        speedFactor: 0.8 + rand.nextDouble() * 0.7,
        delayOffset: rand.nextDouble() * 400.0,
        color: Colors.primaries[rand.nextInt(Colors.primaries.length)],
      ));
    }
  }

  void _startGameTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _gameOver = true;
            _gameController.stop();
            _timer?.cancel();
            _rewardCoins();
          }
        });
      }
    });
  }

  void _rewardCoins() {
    final wallet = Provider.of<WalletProvider>(context, listen: false);
    final int coinsEarned = _score * 5;
    if (coinsEarned > 0) {
      wallet.addCoins(coinsEarned, 'Balloon Pop Arcade Game Reward');
    }
  }

  @override
  void dispose() {
    _gameController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _popBalloon(int id) {
    if (_gameOver) return;
    final index = _balloons.indexWhere((b) => b.id == id);
    if (index != -1 && !_balloons[index].popped) {
      setState(() {
        _balloons[index].popped = true;
        _score++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.blue[50],
      appBar: AppBar(
        title: const Text('BALLOON POP STREAK', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: Stack(
        children: [
          // Game sky board
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _gameController,
              builder: (context, child) {
                return Stack(
                  children: _balloons.map((balloon) {
                    if (balloon.popped) return const SizedBox.shrink();

                    // Calculate ascending height
                    final double animationVal = _gameController.value * balloon.speedFactor;
                    final double yPos = screenHeight - ((animationVal * screenHeight + balloon.delayOffset) % screenHeight);

                    return Positioned(
                      left: MediaQuery.of(context).size.width * balloon.leftPercent,
                      top: yPos,
                      child: GestureDetector(
                        onTapDown: (_) => _popBalloon(balloon.id),
                        child: Container(
                          width: 48,
                          height: 60,
                          decoration: BoxDecoration(
                            color: balloon.color,
                            borderRadius: const BorderRadius.all(Radius.elliptical(24, 30)),
                            boxShadow: [
                              BoxShadow(color: balloon.color.withValues(alpha: 0.3), blurRadius: 8),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Scoreboard Header hud
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _secondsLeft <= 3 ? Colors.red : Colors.blueAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Time: ${_secondsLeft}s',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

          // Game over model overlay
          if (_gameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 80),
                        const SizedBox(height: 16),
                        const Text(
                          'TIME UP!',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You popped $_score balloons!',
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          'Awarded +${_score * 5} Coins!',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'CLAIM REWARDS',
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Balloon {
  final int id;
  final double leftPercent;
  final double speedFactor;
  final double delayOffset;
  final Color color;
  bool popped = false;

  _Balloon({
    required this.id,
    required this.leftPercent,
    required this.speedFactor,
    required this.delayOffset,
    required this.color,
  });
}
