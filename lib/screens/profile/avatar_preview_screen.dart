import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';

class AvatarPreviewScreen extends StatefulWidget {
  const AvatarPreviewScreen({super.key});

  @override
  State<AvatarPreviewScreen> createState() => _AvatarPreviewScreenState();
}

class _AvatarPreviewScreenState extends State<AvatarPreviewScreen> {
  // Active apparel states
  String _selectedTop = 'Crimson Jersey';
  String _selectedBottom = 'Dark Denim';
  String _selectedGlasses = 'Classic Aviators';

  final List<String> _tops = ['Crimson Jersey', 'Navy Blazer', 'White Tee'];
  final List<String> _bottoms = ['Dark Denim', 'Khaki Chinos', 'Running Shorts'];
  final List<String> _glasses = ['Classic Aviators', 'Round Specs', 'None'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('My ShopVerse Avatar', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: Column(
        children: [
          // Avatar Render Board
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141424) : Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base Mannequin Avatar Body Figure
                    const Icon(
                      Icons.person_pin,
                      size: 260,
                      color: Colors.blueGrey,
                    ),

                    // Overlay Tops indicator
                    Positioned(
                      top: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedTop == 'Crimson Jersey'
                              ? Colors.redAccent
                              : _selectedTop == 'Navy Blazer'
                                  ? Colors.indigo
                                  : Colors.white70,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black38),
                        ),
                        child: Text(
                          _selectedTop,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _selectedTop == 'White Tee' ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Overlay Bottoms indicator
                    Positioned(
                      top: 160,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedBottom == 'Dark Denim'
                              ? Colors.blue[900]
                              : _selectedBottom == 'Khaki Chinos'
                                  ? Colors.orange[200]
                                  : Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black38),
                        ),
                        child: Text(
                          _selectedBottom,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _selectedBottom == 'Khaki Chinos' ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Overlay Glasses indicator
                    if (_selectedGlasses != 'None')
                      Positioned(
                        top: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.amber, width: 1.5),
                          ),
                          child: Text(
                            _selectedGlasses,
                            style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Wardrobe Closet Controls Drawer
          Container(
            padding: const EdgeInsets.all(24),
            color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWardrobeRow('Top Shirts', _tops, _selectedTop, (val) => setState(() => _selectedTop = val)),
                const SizedBox(height: 16),
                _buildWardrobeRow('Pants/Jeans', _bottoms, _selectedBottom, (val) => setState(() => _selectedBottom = val)),
                const SizedBox(height: 16),
                _buildWardrobeRow('Glasses/Specs', _glasses, _selectedGlasses, (val) => setState(() => _selectedGlasses = val)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWardrobeRow(String label, List<String> options, String currentSelection, ValueChanged<String> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: options.map((opt) {
            final active = opt == currentSelection;
            return ChoiceChip(
              label: Text(opt, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              selected: active,
              onSelected: (val) {
                if (val) onSelect(opt);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
