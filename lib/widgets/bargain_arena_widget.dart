import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';

class BargainArenaWidget extends StatefulWidget {
  final double originalPrice;
  final ValueChanged<double> onPriceUpdated;

  const BargainArenaWidget({
    super.key,
    required this.originalPrice,
    required this.onPriceUpdated,
  });

  @override
  State<BargainArenaWidget> createState() => _BargainArenaWidgetState();
}

class _BargainArenaWidgetState extends State<BargainArenaWidget> {
  Timer? _timer;
  int _secondsLeft = 60;
  int _slashes = 0;
  double _currentPrice = 0.0;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.originalPrice;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _active = false;
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _slashPrice() {
    if (!_active || _slashes >= 3) return;
    setState(() {
      _slashes++;
      _currentPrice -= 15.0; // Slashes ₹15 per invite click!
    });
    widget.onPriceUpdated(_currentPrice);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend joined! Price slashed by ₹15. Slashes: $_slashes/3.'),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2F) : Colors.purple[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.purple),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BARGAIN ARENA',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.purple),
                    ),
                    Text(
                      'Invite friends to slash this price!',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (_active)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '00:${_secondsLeft.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                )
              else
                const Text('EXPIRED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Slashed Price', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  Text(
                    '₹${_currentPrice.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.purple),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _active && _slashes < 3 ? _slashPrice : null,
                icon: const Icon(Icons.share, size: 14),
                label: Text(
                  _slashes >= 3 ? 'SLASHED MAX' : 'INVITE FRIEND',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar mapping slashes
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _slashes / 3,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation(Colors.purple),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total discount: ₹${(_slashes * 15).toInt()}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
              Text('Slashes: $_slashes/3', style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
