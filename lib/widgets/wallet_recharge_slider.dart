import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';

class WalletRechargeSlider extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;

  const WalletRechargeSlider({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<WalletRechargeSlider> createState() => _WalletRechargeSliderState();
}

class _WalletRechargeSliderState extends State<WalletRechargeSlider> {
  late double _currentVal;

  @override
  void initState() {
    super.initState();
    _currentVal = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Numeric Display indicator
        Text(
          '₹${_currentVal.toInt()}',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary),
        ),
        const SizedBox(height: 12),

        // Scrollable mechanical dial container
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              // Map drag offset to ruler values
              // Every 12 pixels is a ₹50 increment
              final double deltaVal = -(details.primaryDelta! / 12) * 50;
              _currentVal = (_currentVal + deltaVal).clamp(100.0, 5000.0);
              // Snap to nearest 50
              _currentVal = (_currentVal / 50).round() * 50.0;
            });
            widget.onChanged(_currentVal);
          },
          child: Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF12121E) : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Render tick marks
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      painter: _RulerPainter(
                        currentVal: _currentVal,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),

                // Center pointer indicator
                Container(
                  width: 3,
                  height: 48,
                  color: AppColors.brandRed,
                ),
                Positioned(
                  top: 0,
                  child: Icon(Icons.arrow_drop_down, color: AppColors.brandRed, size: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double currentVal;
  final bool isDark;

  _RulerPainter({
    required this.currentVal,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark ? Colors.white30 : Colors.black26
      ..strokeWidth = 1.5;

    final activePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0;

    final center = size.width / 2;
    // Let's assume 12 pixels represents a ₹50 step
    double stepWidth = 12.0;

    // Draw dial markings
    for (double val = 100; val <= 5000; val += 50) {
      // Calculate delta position relative to center pointer
      final double xPos = center + ((val - currentVal) / 50) * stepWidth;

      // Only draw if within bounds
      if (xPos >= 0 && xPos <= size.width) {
        final bool isMajor = (val.toInt() % 500 == 0);
        final double lineLength = isMajor ? 32.0 : 16.0;

        canvas.drawLine(
          Offset(xPos, size.height - lineLength),
          Offset(xPos, size.height),
          isMajor ? activePaint : linePaint,
        );

        if (isMajor) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: '${val.toInt()}',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(xPos - textPainter.width / 2, 8));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) => true;
}
