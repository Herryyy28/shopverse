import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/wallet_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class ScratchCardDialog extends StatefulWidget {
  const ScratchCardDialog({super.key});

  @override
  State<ScratchCardDialog> createState() => _ScratchCardDialogState();
}

class _ScratchCardDialogState extends State<ScratchCardDialog> {
  final List<Offset?> _points = [];
  bool _revealed = false;


  void _checkReveal(Size size) {
    if (_revealed) return;
    
    // Quick approximation of scratch area
    // Count distinct scratched grid cells
    final rows = 10;
    final cols = 10;
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;
    final visited = List.generate(rows, (_) => List.filled(cols, false));

    for (var p in _points) {
      if (p != null) {
        int r = (p.dy / cellHeight).floor().clamp(0, rows - 1);
        int c = (p.dx / cellWidth).floor().clamp(0, cols - 1);
        visited[r][c] = true;
      }
    }

    int count = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (visited[r][c]) count++;
      }
    }

    final pct = count / (rows * cols);
    if (pct > 0.45) {
      setState(() {
        _revealed = true;
        // Reward user with coins as well
        Provider.of<WalletProvider>(context, listen: false).addCoins(10, 'Scratch Card Reward');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard, color: AppColors.brandRed),
                SizedBox(width: 8),
                Text('LUCKY COUPON', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Scratch the card to reveal your discount!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Scratch area
            LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, 180);
                return GestureDetector(
                  onPanUpdate: (details) {
                    final RenderBox box = context.findRenderObject() as RenderBox;
                    final localPos = box.globalToLocal(details.globalPosition);
                    if (localPos.dx >= 0 && localPos.dx <= size.width &&
                        localPos.dy >= 0 && localPos.dy <= size.height) {
                      setState(() {
                        _points.add(localPos);
                      });
                      _checkReveal(size);
                    }
                  },
                  onPanEnd: (_) => _points.add(null),
                  child: Container(
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF12121E) : Colors.yellow[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Secret Revealed Coupon Content
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.stars, color: Colors.amber, size: 36),
                              const SizedBox(height: 8),
                              const Text(
                                '20% OFF FIRST ORDER',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'SECRET20',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              if (_revealed) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  '+10 ShopVerse Coins added!',
                                  style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ]
                            ],
                          ),
                        ),
                        
                        // Scratch Overlay Layer
                        if (!_revealed)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ScratchPainter(points: _points),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'CLOSE',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  final List<Offset?> points;
  _ScratchPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paintCoating = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;
    
    // Draw shine line
    final paintPattern = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    
    // Fill background coating color
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      paintCoating,
    );

    // Draw some scratch lines
    for (double i = -50; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i + 50, size.height), paintPattern);
    }

    // Draw Scratch instruction text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SCRATCH WITH FINGER',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
    );

    // Apply eraser paths
    final paintEraser = Paint()
      ..strokeWidth = 36.0
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.clear;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paintEraser);
      }
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter oldDelegate) => true;
}
