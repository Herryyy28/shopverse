import 'package:flutter/material.dart';
import 'package:imageview360/imageview360.dart';
import '../utils/app_colors.dart';

class View360Dialog extends StatefulWidget {
  final List<String> imageList;

  const View360Dialog({super.key, required this.imageList});

  @override
  State<View360Dialog> createState() => _View360DialogState();
}

class _View360DialogState extends State<View360Dialog> {
  bool _imagePrecached = false;

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
    return Dialog(
      backgroundColor: Colors.white,
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
            if (_imagePrecached)
              ImageView360(
                key: UniqueKey(),
                imageList: widget.imageList.map((url) => NetworkImage(url)).toList(),
                autoRotate: true,
                rotationCount: 2,
                swipeSensitivity: 2,
                allowSwipeToRotate: true,
                onImageIndexChanged: (currentImageIndex) {},
              )
            else
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.brandRed),
                    SizedBox(height: 16),
                    Text('Loading 360° view...'),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Swipe to rotate manually',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
