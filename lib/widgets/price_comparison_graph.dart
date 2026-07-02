import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';

class PriceComparisonGraph extends StatelessWidget {
  final double currentPrice;

  const PriceComparisonGraph({
    super.key,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_down, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Price Fluctuation & Match',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Paint historical 30-day graph line
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: _HistoricalChartPainter(isDark: isDark, basePrice: currentPrice),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('30 days ago', style: TextStyle(color: AppColors.textSecondary, fontSize: 9)),
              Text('Lowest: ₹99', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
              Text('Today', style: TextStyle(color: AppColors.textSecondary, fontSize: 9)),
            ],
          ),
          const Divider(height: 24),

          // Competitors match table
          const Text('Real-Time Price Match', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          _buildCompetitorRow('ShopVerse (This App)', currentPrice, Colors.green, isBest: true),
          const SizedBox(height: 8),
          _buildCompetitorRow('Amazon India', currentPrice + 35, AppColors.textSecondary),
          const SizedBox(height: 8),
          _buildCompetitorRow('Flipkart', currentPrice + 18, AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildCompetitorRow(String label, double price, Color color, {bool isBest = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isBest ? Icons.verified_user : Icons.store_outlined,
              color: isBest ? Colors.green : Colors.grey,
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              '₹${price.toInt()}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
            if (isBest) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BEST DEAL',
                  style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ]
          ],
        ),
      ],
    );
  }
}

class _HistoricalChartPainter extends CustomPainter {
  final bool isDark;
  final double basePrice;

  _HistoricalChartPainter({required this.isDark, required this.basePrice});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final linePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.green.withValues(alpha: 0.3), Colors.green.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw horizontal grids
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), gridPaint);

    final path = Path();
    final fillPath = Path();

    // Map 30 points of simulated fluctuation data
    final rand = Random(42); // fixed seed
    path.moveTo(0, size.height * 0.6);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height * 0.6);

    double xStep = size.width / 10;
    for (int i = 1; i <= 10; i++) {
      double x = i * xStep;
      double y = size.height * 0.3 + rand.nextDouble() * size.height * 0.5;
      if (i == 10) y = size.height * 0.4; // end near current price
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _HistoricalChartPainter oldDelegate) => false;
}
