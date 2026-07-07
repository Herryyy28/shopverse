import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';


class PriceTrackerWidget extends StatefulWidget {
  final double currentPrice;
  final double oldPrice;

  const PriceTrackerWidget({
    super.key,
    required this.currentPrice,
    required this.oldPrice,
  });

  @override
  State<PriceTrackerWidget> createState() => _PriceTrackerWidgetState();
}

class _PriceTrackerWidgetState extends State<PriceTrackerWidget> {
  bool _alertEnabled = false;
  final TextEditingController _priceThresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default alert threshold at 10% below current price
    _priceThresholdController.text = (widget.currentPrice * 0.9).toInt().toString();
  }

  @override
  void dispose() {
    _priceThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Generate historical mock data drops
    final double maxPrice = widget.oldPrice > widget.currentPrice ? widget.oldPrice : widget.currentPrice * 1.25;
    final double minPrice = widget.currentPrice * 0.85;
    final List<double> history = [
      maxPrice,
      maxPrice * 0.95,
      maxPrice * 0.98,
      widget.oldPrice > 0 ? widget.oldPrice : maxPrice * 0.90,
      widget.currentPrice * 1.05,
      widget.currentPrice,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Price History (Last 30 Days)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'BEST PRICE NOW',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Custom painted line sparkline
          SizedBox(
            height: 80,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(
                data: history,
                min: minPrice,
                max: maxPrice,
                lineColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Price alerts section
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price Drop Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    'Get notified if the price goes below threshold',
                    style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 10),
                  ),
                ],
              ),
              Switch(
                value: _alertEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _alertEnabled = val;
                  });
                  if (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Alert configured for price: ₹${_priceThresholdController.text}!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          if (_alertEnabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Alert threshold: ₹', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 4),
                SizedBox(
                  width: 80,
                  height: 36,
                  child: TextField(
                    controller: _priceThresholdController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Target drop config active',
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final double min;
  final double max;
  final Color lineColor;

  _SparklinePainter({
    required this.data,
    required this.min,
    required this.max,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final double widthInterval = size.width / (data.length - 1);
    final double heightRange = max - min;

    final path = Path();
    final fillPath = Path();

    // Calculate vertical scaling offset
    double getY(double val) {
      final double scaledY = size.height - (((val - min) / heightRange) * size.height);
      return scaledY.clamp(4.0, size.height - 4.0);
    }

    final startPoint = Offset(0, getY(data.first));
    path.moveTo(startPoint.dx, startPoint.dy);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(startPoint.dx, startPoint.dy);

    for (int i = 1; i < data.length; i++) {
      final pt = Offset(i * widthInterval, getY(data[i]));
      path.lineTo(pt.dx, pt.dy);
      fillPath.lineTo(pt.dx, pt.dy);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), gridPaint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), gridPaint);

    // Draw line fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withValues(alpha: 0.24), lineColor.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw sparkline path
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw indicator point at final index
    final pointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final lastPoint = Offset(size.width, getY(data.last));
    canvas.drawCircle(lastPoint, 5.0, pointPaint);
    canvas.drawCircle(lastPoint, 5.0, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}
