import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';

class FlashDealRadar extends StatefulWidget {
  const FlashDealRadar({super.key});

  @override
  State<FlashDealRadar> createState() => _FlashDealRadarState();
}

class _FlashDealRadarState extends State<FlashDealRadar> with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;
  bool _showNode = false;
  Offset _nodePos = Offset.zero;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Periodically show target deal nodes
    _sweepController.addListener(() {
      if (_sweepController.value > 0.4 && _sweepController.value < 0.42 && !_showNode) {
        setState(() {
          _showNode = true;
          // Position relative to a 140x140 radar canvas bounds
          _nodePos = const Offset(100.0, 45.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  void _revealDeal() {
    setState(() {
      _showNode = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
          title: const Row(
            children: [
              Icon(Icons.gps_fixed, color: Colors.green),
              SizedBox(width: 8),
              Text('RADAR SIGNAL MATCH!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: const Text(
            'Secret coupon detected! Save 35% on all Footwear items using coupon code:\n\nRADAR35',
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLAIM REWARD', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141424) : Colors.green[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Row(
        children: [
          // Radar scope
          GestureDetector(
            onTap: () {
              if (_showNode) _revealDeal();
            },
            child: SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _sweepController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(110, 110),
                        painter: _RadarPainter(angle: _sweepController.value * 2 * pi),
                      );
                    },
                  ),
                  if (_showNode)
                    Positioned(
                      left: _nodePos.dx,
                      top: _nodePos.dy,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.greenAccent, blurRadius: 12, spreadRadius: 4),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Message details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.radar_rounded, color: Colors.green, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'DEAL RADAR',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _showNode ? 'SIGNAL MATCH! Tap the green dot on the radar.' : 'Scanning for active secret flash codes...',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Keep this dashboard open to scan coordinates.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double angle;
  _RadarPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background scope lines
    final bgPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawCircle(center, radius * 0.66, bgPaint);
    canvas.drawCircle(center, radius * 0.33, bgPaint);
    
    // Draw crosshair axes
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), bgPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), bgPaint);

    // Draw rotating sweep sweep line
    final sweepPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0;

    final endPoint = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    canvas.drawLine(center, endPoint, sweepPaint);

    // Draw trailing sweeping glow
    final trailPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.green.withValues(alpha: 0.4), Colors.transparent],
        stops: const [0.0, 0.25],
        transform: GradientRotation(angle - 0.25 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, trailPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}
