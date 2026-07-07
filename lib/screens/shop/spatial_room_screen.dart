import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';

class SpatialRoomScreen extends StatefulWidget {
  const SpatialRoomScreen({super.key});

  @override
  State<SpatialRoomScreen> createState() => _SpatialRoomScreenState();
}

class _SpatialRoomScreenState extends State<SpatialRoomScreen> {
  // Mock background room viewfinder image
  final String _roomBg = "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800";

  final List<Map<String, String>> _furnitureList = [
    {
      'name': 'Minimalist Sofa',
      'url': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=300',
    },
    {
      'name': 'Potted Monstrera',
      'url': 'https://images.unsplash.com/photo-1545241047-6083a3684587?w=300',
    },
    {
      'name': 'Modern TV Stand',
      'url': 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=300',
    }
  ];

  String _activeFurnitureUrl = "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=300";

  double _xPosition = 100.0;
  double _yPosition = 150.0;
  double _scale = 1.0;
  double _rotation = 0.0;

  double _baseScale = 1.0;
  double _baseRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Spatial AR Preview', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: Column(
        children: [
          // Viewfinder Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mock Room Camera View
                    Image.network(
                      _roomBg,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),

                    // Grid Overlay mapping spatial depth
                    Opacity(
                      opacity: 0.15,
                      child: GridPaper(
                        color: Colors.cyan[200]!,
                        interval: 100,
                        divisions: 2,
                        subdivisions: 2,
                        child: const SizedBox(width: double.infinity, height: double.infinity),
                      ),
                    ),

                    // Draggable and rotatable furniture model preview
                    Positioned(
                      left: _xPosition,
                      top: _yPosition,
                      child: GestureDetector(
                        onScaleStart: (details) {
                          _baseScale = _scale;
                          _baseRotation = _rotation;
                        },
                        onScaleUpdate: (details) {
                          setState(() {
                            // Scale translation
                            _scale = (_baseScale * details.scale).clamp(0.4, 2.5);
                            // Rotation angle modification
                            _rotation = _baseRotation + details.rotation;
                            
                            _xPosition += details.focalPointDelta.dx;
                            _yPosition += details.focalPointDelta.dy;
                          });
                        },
                        child: Transform.rotate(
                          angle: _rotation,
                          child: Transform.scale(
                            scale: _scale,
                            child: Container(
                              width: 160,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.cyan.withValues(alpha: 0.4), width: 1.5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _activeFurnitureUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Guidance UI
                    Positioned(
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.crop_free, color: Colors.cyanAccent, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Pinch to rotate & scale furniture model',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Items Grid Selection
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose Furniture Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _furnitureList.length,
                    itemBuilder: (context, index) {
                      final item = _furnitureList[index];
                      final isSelected = _activeFurnitureUrl == item['url'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeFurnitureUrl = item['url']!;
                            _xPosition = 100;
                            _yPosition = 150;
                            _scale = 1.0;
                            _rotation = 0.0;
                          });
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 3.0,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(item['url']!, fit: BoxFit.cover),
                                Container(
                                  color: Colors.black38,
                                  alignment: Alignment.bottomCenter,
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    item['name']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
