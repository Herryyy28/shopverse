import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class VirtualTryonScreen extends StatefulWidget {
  const VirtualTryonScreen({super.key});

  @override
  State<VirtualTryonScreen> createState() => _VirtualTryonScreenState();
}

class _VirtualTryonScreenState extends State<VirtualTryonScreen> {
  String _selectedModel = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600";
  
  final List<String> _modelsList = [
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600", // Female Model
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600", // Male Model
  ];

  final List<Map<String, String>> _fittingItems = [
    {
      'name': 'Tortoise Glasses',
      'url': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=200', // Sunglasses png cutout or square
    },
    {
      'name': 'Midnight Purple Headset',
      'url': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200',
    }
  ];

  String _activeFittingUrl = "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=200";

  // Position coordinates for overlay item
  double _xPosition = 120.0;
  double _yPosition = 120.0;
  double _scale = 1.0;
  double _baseScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Virtual Try-On (AI)', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: Column(
        children: [
          // Main Try-On Viewport
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mannequin/Model picture background
                    Image.network(
                      _selectedModel,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),

                    // Draggable/Resizable try-on item
                    Positioned(
                      left: _xPosition,
                      top: _yPosition,
                      child: GestureDetector(
                        onScaleStart: (details) {
                          _baseScale = _scale;
                        },
                        onScaleUpdate: (details) {
                          setState(() {
                            // Update scale factor
                            _scale = (_baseScale * details.scale).clamp(0.5, 3.0);
                            
                            // Track drag translations
                            _xPosition += details.focalPointDelta.dx;
                            _yPosition += details.focalPointDelta.dy;
                          });
                        },
                        child: Transform.scale(
                          scale: _scale,
                          child: Container(
                            width: 120,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.network(
                              _activeFittingUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Controls Instruction overlay
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Drag or pinch to adjust fitting',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Selection Bar
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('1. Select Mannequin Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _modelsList.length,
                    itemBuilder: (context, index) {
                      final url = _modelsList[index];
                      final isSelected = _selectedModel == url;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedModel = url),
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 3.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(url, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text('2. Choose Accessory Fitting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  children: _fittingItems.map((item) {
                    final isSelected = _activeFittingUrl == item['url'];
                    return ChoiceChip(
                      label: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _activeFittingUrl = item['url']!;
                            // Reset positions
                            _xPosition = 120;
                            _yPosition = 120;
                            _scale = 1.0;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
