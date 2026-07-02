import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:shopverse/providers/wallet_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class SpinWheelDialog extends StatefulWidget {
  const SpinWheelDialog({super.key});

  @override
  State<SpinWheelDialog> createState() => _SpinWheelDialogState();
}

class _SpinWheelDialogState extends State<SpinWheelDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ConfettiController _confettiController;
  
  final List<int> _sectors = [10, 50, 5, 100, 20, 15, 0, 30];
  final List<Color> _colors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellow[700]!,
    Colors.greenAccent[400]!,
    Colors.blueAccent,
    Colors.indigoAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
  ];

  bool _isSpinning = false;
  int _resultCoins = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _resultCoins = 0;
    });

    final random = Random();
    // Choose a random sector index to win
    final targetIndex = random.nextInt(_sectors.length);
    final sectorAngle = (2 * pi) / _sectors.length;
    
    // Angle corresponding to the center of the target sector (starting from top, moving counter-clockwise)
    final targetAngle = (2 * pi) - (targetIndex * sectorAngle) - (sectorAngle / 2);
    
    // Add 5 complete rotations for speed effect
    final totalRotation = (10 * pi) + targetAngle;

    _animation = Tween<double>(begin: 0, end: totalRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward(from: 0).then((_) {
      final wonCoins = _sectors[targetIndex];
      Provider.of<WalletProvider>(context, listen: false).spinWheel(wonCoins);
      
      setState(() {
        _resultCoins = wonCoins;
        _isSpinning = false;
      });

      if (wonCoins > 0) {
        _confettiController.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'DAILY SPIN WHEEL',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Spin to win premium ShopVerse Coins!',
                  style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Wheel View with indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer border
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final angle = _controller.isAnimating ? _animation.value : 0.0;
                          return Transform.rotate(
                            angle: angle,
                            child: CustomPaint(
                              painter: _WheelPainter(sectors: _sectors, colors: _colors, textColor: isDark ? Colors.white : Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Pin Pointer at top
                    Positioned(
                      top: 0,
                      child: CustomPaint(
                        size: const Size(20, 24),
                        painter: _PinPainter(),
                      ),
                    ),

                    // Center Hub Button
                    GestureDetector(
                      onTap: _isSpinning ? null : _spin,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'SPIN',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_resultCoins > 0) ...[
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text(
                                  'CONGRATS! You won $_resultCoins Coins!',
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.amber, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ] else if (_resultCoins == 0 && !_isSpinning && _controller.value == 1.0) ...[
                  const Text(
                    'Better luck next time! 🍀',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'CLOSE',
                    onPressed: _isSpinning ? null : () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          
          // Confetti celebratory animation
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<int> sectors;
  final List<Color> colors;
  final Color textColor;

  _WheelPainter({required this.sectors, required this.colors, required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final center = Offset(radius, radius);
    final sectorAngle = (2 * pi) / sectors.length;

    for (int i = 0; i < sectors.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      // Draw Sector Arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sectorAngle - (pi / 2) - (sectorAngle / 2),
        sectorAngle,
        true,
        paint,
      );

      // Draw Labels
      canvas.save();
      canvas.translate(radius, radius);
      
      // Calculate rotation for text centering
      final double textRotation = i * sectorAngle;
      canvas.rotate(textRotation);

      // Translate slightly outwards
      canvas.translate(0, -radius * 0.65);

      final textPainter = TextPainter(
        text: TextSpan(
          text: sectors[i] == 0 ? 'Try' : '${sectors[i]}',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawShadow(path, Colors.black, 4.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
