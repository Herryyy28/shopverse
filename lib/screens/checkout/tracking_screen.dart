import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _currentStep = 0; // 0: Finding, 1: Received, 2: Packed, 3: On the way, 4: Delivered
  double _rating = 0;
  bool _showRatingDialog = false;

  @override
  void initState() {
    super.initState();
    _simulateProgress();
  }

  void _simulateProgress() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _currentStep = 1);
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => _currentStep = 2);
    await Future.delayed(const Duration(seconds: 6));
    if (mounted) setState(() => _currentStep = 3);
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) setState(() => _currentStep = 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getStatusText(),
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
            ),
            Text('Order ${widget.orderId}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Map Area
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      // Map positions dynamically
                      double markerTop = h - 100;
                      double markerLeft = 20;

                      if (_currentStep == 1) {
                        markerTop = h * 0.8;
                        markerLeft = w * 0.15;
                      } else if (_currentStep == 2) {
                        markerTop = h * 0.55;
                        markerLeft = w * 0.55;
                      } else if (_currentStep == 3) {
                        markerTop = h * 0.35;
                        markerLeft = w * 0.28;
                      } else if (_currentStep == 4) {
                        markerTop = h * 0.15;
                        markerLeft = w * 0.65;
                      }

                      return Stack(
                        children: [
                          Opacity(
                            opacity: 0.4,
                            child: Image.network(
                              'https://miro.medium.com/v2/resize:fit:1400/1*qV92Z4S9uY-59uO1I4iCqg.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Route path overlay
                          if (_currentStep > 0)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _RoutePainter(currentStep: _currentStep),
                              ),
                            ),
                          if (_currentStep == 0) _buildFindingPartnerOverlay(),
                          if (_currentStep > 0)
                            AnimatedPositioned(
                              duration: const Duration(seconds: 3),
                              curve: Curves.easeInOut,
                              top: markerTop - 35,
                              left: markerLeft - 25,
                              child: _currentStep < 4 ? _buildRiderMarker() : _buildDeliveryMarker(),
                            ),
                        ],
                      );
                    }
                  ),
                ),
              ),
              
              // Status Panel
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildStep(
                          icon: Icons.receipt_long,
                          title: 'Order Received',
                          subtitle: 'Wait for shop to accept',
                          isDone: _currentStep >= 1,
                          isActive: _currentStep == 1,
                        ),
                        _buildStep(
                          icon: Icons.local_mall,
                          title: 'Order Packed',
                          subtitle: 'Ready for pickup',
                          isDone: _currentStep >= 2,
                          isActive: _currentStep == 2,
                        ),
                        _buildStep(
                          icon: Icons.delivery_dining,
                          title: 'Out for Delivery',
                          subtitle: 'Rider is on the way',
                          isDone: _currentStep >= 3,
                          isActive: _currentStep == 3,
                        ),
                        _buildStep(
                          icon: Icons.home,
                          title: 'Delivered',
                          subtitle: 'Enjoy your meal!',
                          isDone: _currentStep >= 4,
                          isActive: _currentStep == 4,
                        ),
                        if (_currentStep == 4) ...[
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'RATE EXPERIENCE',
                            onPressed: () => setState(() => _showRatingDialog = true),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
              
              // Rider Card
              _buildRiderCard(),
            ],
          ),
          if (_showRatingDialog) _buildRatingOverlay(),
        ],
      ),
    );
  }

  Widget _buildFindingPartnerOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      width: double.infinity,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Finding delivery partner nearby...',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Assigning someone to your order',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (_currentStep) {
      case 0: return 'Processing...';
      case 1: return 'Order Received';
      case 2: return 'Order Packed';
      case 3: return 'Arriving in 4 mins';
      case 4: return 'Order Delivered';
      default: return 'Tracking...';
    }
  }

  Widget _buildRiderMarker() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
          child: const Text('Rider is moving', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const Icon(Icons.delivery_dining, color: AppColors.brandRed, size: 40),
      ],
    );
  }

  Widget _buildDeliveryMarker() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
          child: const Text('Delivered', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const Icon(Icons.location_on, color: Colors.green, size: 40),
      ],
    );
  }

  Widget _buildRiderCard() {
    if (_currentStep == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=rider_herry'),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rahul Kumar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(' 4.8 • ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('Delivery Partner', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.call, color: Colors.white, size: 20)),
          ),
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.message, color: Colors.white, size: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({required IconData icon, required String title, required String subtitle, required bool isDone, required bool isActive}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? Colors.green.withValues(alpha: 0.1) : Colors.grey[100],
            ),
            child: Icon(isDone ? Icons.check_circle : icon, size: 18, color: isDone ? Colors.green : Colors.grey[400]),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: isActive ? Colors.black : (isDone ? Colors.black87 : Colors.grey))),
              Text(subtitle, style: TextStyle(fontSize: 12, color: isDone ? Colors.black54 : Colors.grey[400])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingOverlay() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rate Your Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('How was the delivery by Rahul?', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () => setState(() => _rating = index + 1.0),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Add a comment (Optional)',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'SUBMIT FEEDBACK',
              onPressed: () {
                setState(() => _showRatingDialog = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final int currentStep;

  _RoutePainter({required this.currentStep});

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(size.width * 0.15, size.height * 0.8);
    final p2 = Offset(size.width * 0.55, size.height * 0.55);
    final p3 = Offset(size.width * 0.28, size.height * 0.35);
    final p4 = Offset(size.width * 0.65, size.height * 0.15);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..cubicTo(
        (p1.dx + p2.dx) / 2, p1.dy,
        p2.dx, (p1.dy + p2.dy) / 2,
        p2.dx, p2.dy,
      )
      ..cubicTo(
        p2.dx, (p2.dy + p3.dy) / 2,
        p3.dx, (p2.dy + p3.dy) / 2,
        p3.dx, p3.dy,
      )
      ..cubicTo(
        p3.dx, (p3.dy + p4.dy) / 2,
        (p3.dx + p4.dx) / 2, p4.dy,
        p4.dx, p4.dy,
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final pathPaint = Paint()
      ..color = AppColors.brandRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Draw full road path background
    canvas.drawPath(path, backgroundPaint);

    // Draw active glowing path depending on the current step
    final activePath = Path()..moveTo(p1.dx, p1.dy);
    if (currentStep >= 1) {
      activePath.cubicTo(
        (p1.dx + p2.dx) / 2, p1.dy,
        p2.dx, (p1.dy + p2.dy) / 2,
        p2.dx, p2.dy,
      );
    }
    if (currentStep >= 2) {
      activePath.cubicTo(
        p2.dx, (p2.dy + p3.dy) / 2,
        p3.dx, (p2.dy + p3.dy) / 2,
        p3.dx, p3.dy,
      );
    }
    if (currentStep >= 3) {
      activePath.cubicTo(
        p3.dx, (p3.dy + p4.dy) / 2,
        (p3.dx + p4.dx) / 2, p4.dy,
        p4.dx, p4.dy,
      );
    }

    canvas.drawPath(activePath, pathPaint);

    // Draw nodes/hubs
    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final List<Offset> points = [p1, p2, p3, p4];
    for (int i = 0; i < points.length; i++) {
      final isCompleted = currentStep >= i;
      borderPaint.color = isCompleted ? Colors.green : Colors.grey;
      canvas.drawCircle(points[i], 8.0, nodePaint);
      canvas.drawCircle(points[i], 8.0, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.currentStep != currentStep;
}
