import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../utils/app_colors.dart';

class ARPreviewDialog extends StatelessWidget {
  final String modelUrl;
  final String productName;

  const ARPreviewDialog({
    super.key,
    required this.modelUrl,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          ModelViewer(
            backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
            src: modelUrl,
            alt: "A 3D model of $productName",
            ar: true,
            autoRotate: true,
            cameraControls: true,
            loading: Loading.eager,
            arModes: const ['scene-viewer', 'webxr', 'quick-look'],
          ),
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.view_in_ar, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Place in your space',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
