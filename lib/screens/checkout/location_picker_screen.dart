import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Map viewport pan offsets
  double _mapX = 0.0;
  double _mapY = 0.0;

  double get _latitude => 28.6139 - (_mapY / 12000);
  double get _longitude => 77.2090 + (_mapX / 12000);

  String get _currentAddress {
    final sector = ((_mapX.abs() + _mapY.abs()) / 40).floor() % 12 + 1;
    final block = String.fromCharCode(65 + (((_mapX.abs() * 2) / 60).floor() % 6));
    return "Block $block-$sector, Connaught Place, New Delhi, Delhi 110001";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Confirm Delivery Location', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: Column(
        children: [
          // Map Canvas Box
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Scrollable Vector Map Background Canvas
                GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _mapX += details.delta.dx;
                      _mapY += details.delta.dy;
                    });
                  },
                  child: Container(
                    color: isDark ? const Color(0xFF141424) : const Color(0xFFE5E7EB),
                    width: double.infinity,
                    height: double.infinity,
                    child: CustomPaint(
                      painter: _VectorMapPainter(
                        offsetX: _mapX,
                        offsetY: _mapY,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),

                // Stationary Center Pin Indicator
                IgnorePointer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                        ),
                        child: const Text(
                          'DELIVER HERE',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                        ),
                      ),
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.brandRed,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Metadata Drawer
          Container(
            padding: const EdgeInsets.all(24),
            color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.blueAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Selected Address:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  _currentAddress,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'CONFIRM LOCATION',
                        onPressed: () {
                          Navigator.pop(context, _currentAddress);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VectorMapPainter extends CustomPainter {
  final double offsetX;
  final double offsetY;
  final bool isDark;

  _VectorMapPainter({
    required this.offsetX,
    required this.offsetY,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Canvas styling
    final roadPaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.white
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final buildingPaint = Paint()
      ..color = isDark ? const Color(0xFF1E1E2F) : const Color(0xFFD1D5DB)
      ..style = PaintingStyle.fill;

    // Draw some mock grids representing map coordinates
    final double spacing = 180.0;
    
    // Draw vector roads shifting with offsets
    for (double i = -spacing * 2; i < size.width + spacing * 2; i += spacing) {
      // Vertical roads
      canvas.drawLine(
        Offset(i + offsetX % spacing, -size.height),
        Offset(i + offsetX % spacing, size.height * 2),
        roadPaint,
      );
      // Horizontal roads
      canvas.drawLine(
        Offset(-size.width, i + offsetY % spacing),
        Offset(size.width * 2, i + offsetY % spacing),
        roadPaint,
      );
    }

    // Draw mock block outlines inside grids
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final double cellX = x + offsetX % spacing + 20;
        final double cellY = y + offsetY % spacing + 20;
        final rect = Rect.fromLTWH(cellX, cellY, spacing - 40, spacing - 40);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), buildingPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VectorMapPainter oldDelegate) => true;
}
