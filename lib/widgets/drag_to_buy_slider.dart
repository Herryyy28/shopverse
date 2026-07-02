import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';

class DragToBuySlider extends StatefulWidget {
  final VoidCallback onConfirmed;
  final double price;

  const DragToBuySlider({
    super.key,
    required this.onConfirmed,
    required this.price,
  });

  @override
  State<DragToBuySlider> createState() => _DragToBuySliderState();
}

class _DragToBuySliderState extends State<DragToBuySlider> {
  double _dragOffset = 0.0;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - 56.0; // handle size is 50.0 + margins

        return Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2F) : Colors.grey[100],
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Sliding track background text
              Center(
                child: Text(
                  _confirmed ? 'ORDER PLACED!' : 'SLIDE TO BUY (₹${widget.price.toInt()})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _confirmed
                        ? Colors.green
                        : isDark
                            ? Colors.white30
                            : Colors.black38,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              // Draggable circle handle
              Positioned(
                left: _dragOffset,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_confirmed) return;
                    setState(() {
                      _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_confirmed) return;
                    if (_dragOffset >= maxDrag * 0.95) {
                      setState(() {
                        _dragOffset = maxDrag;
                        _confirmed = true;
                      });
                      widget.onConfirmed();
                    } else {
                      setState(() {
                        _dragOffset = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _confirmed
                            ? [Colors.green, Colors.greenAccent[700]!]
                            : [AppColors.brandRed, const Color(0xFFE52E2E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: Icon(
                      _confirmed ? Icons.check : Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
