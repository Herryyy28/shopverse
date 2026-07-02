import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/utils/app_colors.dart';

class View360Dialog extends StatefulWidget {
  final List<String> imageList;

  const View360Dialog({super.key, required this.imageList});

  @override
  State<View360Dialog> createState() => _View360DialogState();
}

class _View360DialogState extends State<View360Dialog> {
  bool _imagePrecached = false;
  int _currentFrame = 0;
  double _dragProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _precacheImages();
  }

  void _precacheImages() async {
    for (String url in widget.imageList) {
      await precacheImage(NetworkImage(url), context);
    }
    if (mounted) {
      setState(() {
        _imagePrecached = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '360° PRODUCT VIEW',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_imagePrecached && widget.imageList.isNotEmpty) ...[
              // Gesture rotation detector
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragProgress += details.primaryDelta! / 10;
                    if (_dragProgress.abs() >= 1.0) {
                      final change = _dragProgress.floor();
                      _currentFrame = (_currentFrame - change) % widget.imageList.length;
                      if (_currentFrame < 0) {
                        _currentFrame += widget.imageList.length;
                      }
                      _dragProgress -= change;
                    }
                  });
                },
                child: Container(
                  height: 220,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black12 : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageList[_currentFrame],
                    fit: BoxFit.contain,
                    placeholder: (c, u) => const Center(child: CircularProgressIndicator(color: AppColors.brandRed)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Scrubbing Slider bar
              Slider(
                value: _currentFrame.toDouble(),
                min: 0,
                max: (widget.imageList.length - 1).toDouble(),
                activeColor: AppColors.primary,
                inactiveColor: isDark ? Colors.white12 : Colors.black12,
                onChanged: (val) {
                  setState(() {
                    _currentFrame = val.toInt();
                  });
                },
              ),
            ] else
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.brandRed),
                    SizedBox(height: 16),
                    Text('Loading 360° view...'),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Drag image or use slider to rotate manually',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
