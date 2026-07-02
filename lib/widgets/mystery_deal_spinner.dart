import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class MysteryDealSpinner extends StatefulWidget {
  const MysteryDealSpinner({super.key});

  @override
  State<MysteryDealSpinner> createState() => _MysteryDealSpinnerState();
}

class _MysteryDealSpinnerState extends State<MysteryDealSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _spinning = false;
  bool _finished = false;
  String _wonCategory = '';
  double _wonPrice = 0.0;
  String _wonDescription = '';

  final List<Map<String, dynamic>> _dealSegments = [
    {'label': 'Tech Accessories Box', 'price': 199.0, 'desc': 'Includes smart charging cube + premium braided cable'},
    {'label': 'Sneakers Box', 'price': 499.0, 'desc': 'Includes lightweight memory foam running shoes'},
    {'label': 'Gourmet Pantry Box', 'price': 99.0, 'desc': 'Includes salted butter + chocolate chip cookies pack'},
    {'label': 'Wearables Mystery', 'price': 299.0, 'desc': 'Includes fitness trackers or silicon strap watch bands'},
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _spinWheel() async {
    if (_spinning || _finished) return;

    setState(() {
      _spinning = true;
    });

    // Spin rapidly and slow down
    _rotationController.repeat();
    await Future.delayed(const Duration(seconds: 3));
    
    // Pick random segment index
    final rand = Random();
    final index = rand.nextInt(_dealSegments.length);
    final win = _dealSegments[index];

    _rotationController.stop();

    if (mounted) {
      setState(() {
        _spinning = false;
        _finished = true;
        _wonCategory = win['label'] as String;
        _wonPrice = win['price'] as double;
        _wonDescription = win['desc'] as String;
      });
    }
  }

  void _claimDeal() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    final mysteryProduct = Product(
      id: 'mystery_deal_${DateTime.now().millisecond}',
      name: 'Mystery Box: $_wonCategory',
      brand: 'SHOPVERSE SECRET',
      description: _wonDescription,
      price: _wonPrice,
      imageUrl: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=800',
      category: 'Mystery Box',
    );

    cart.addItem(mysteryProduct);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Claimed Mystery Box: $_wonCategory added to bag!'),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MYSTERY BOX DEAL SPINNER',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Spin to unlock high-discount secret items!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 24),

              // Spinning wheel visualizer canvas
              Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: _rotationController,
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: _SpinnerPiePainter(isDark: isDark),
                      ),
                    ),
                  ),

                  // Center spinner pointer pin
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
                ],
              ),
              const SizedBox(height: 24),

              if (!_spinning && !_finished)
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'SPIN WHEEL FOR ₹99+',
                    onPressed: _spinWheel,
                  ),
                )
              else if (_spinning)
                const Column(
                  children: [
                    Text('Spinning wheel...', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    SizedBox(height: 8),
                    CircularProgressIndicator(color: Colors.blueAccent),
                  ],
                )
              else if (_finished) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'CONGRATULATIONS!',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.purple, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _wonCategory,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _wonDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Unlock Special Price: ₹${_wonPrice.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'CLAIM DEAL',
                        onPressed: _claimDeal,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SpinnerPiePainter extends CustomPainter {
  final bool isDark;
  _SpinnerPiePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.purpleAccent[100]!,
      Colors.blueAccent[100]!,
      Colors.amberAccent[100]!,
      Colors.pinkAccent[100]!,
    ];

    final double sweepAngle = 2 * pi / 4;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, i * sweepAngle, sweepAngle, true, paint);

      // Draw segment separating lines
      final borderPaint = Paint()
        ..color = isDark ? Colors.white24 : Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawArc(rect, i * sweepAngle, sweepAngle, true, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpinnerPiePainter oldDelegate) => false;
}
