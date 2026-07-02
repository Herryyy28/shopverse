import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class VoiceVisualizerDialog extends StatefulWidget {
  const VoiceVisualizerDialog({super.key});

  @override
  State<VoiceVisualizerDialog> createState() => _VoiceVisualizerDialogState();
}

class _VoiceVisualizerDialogState extends State<VoiceVisualizerDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isListening = true;
  String _recognizedText = "Listening to voice input...";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Simulate voice parsing steps
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _recognizedText = '“Search for red sports running shoes”';
        });
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _recognizedText = 'Done! Filtering products catalog...';
          _isListening = false;
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, "red sports running shoes");
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            const Text(
              'VOICE SEARCH AI',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
            ),
            const SizedBox(height: 32),

            // Pulsing Mic Circle
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: 90 + sin(_animationController.value * pi) * 15,
                      height: 90 + sin(_animationController.value * pi) * 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.withValues(alpha: 0.15),
                      ),
                    );
                  },
                ),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: _isListening ? Colors.blueAccent : Colors.green,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.check,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Waveform visualizer container
            if (_isListening)
              SizedBox(
                height: 50,
                width: 200,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _WaveformPainter(value: _animationController.value),
                    );
                  },
                ),
              )
            else
              const SizedBox(height: 50),

            const SizedBox(height: 24),
            Text(
              _recognizedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _isListening ? AppColors.textSecondary : Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'CANCEL',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double value;
  _WaveformPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final wave1 = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final wave2 = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path1 = Path();
    final path2 = Path();

    path1.moveTo(0, size.height / 2);
    path2.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      // Compute overlapping phase offset sine waves
      final y1 = size.height / 2 + sin((x / size.width * 2 * pi * 2.5) + value * 2 * pi) * 16 * sin(value * pi);
      final y2 = size.height / 2 + cos((x / size.width * 2 * pi * 3.5) - value * 2 * pi) * 12 * sin(value * pi);
      
      path1.lineTo(x, y1);
      path2.lineTo(x, y2);
    }

    canvas.drawPath(path1, wave1);
    canvas.drawPath(path2, wave2);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}
