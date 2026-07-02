import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class VariantDesignerScreen extends StatefulWidget {
  const VariantDesignerScreen({super.key});

  @override
  State<VariantDesignerScreen> createState() => _VariantDesignerScreenState();
}

class _VariantDesignerScreenState extends State<VariantDesignerScreen> {
  // Customized shoe color states
  Color _meshColor = Colors.redAccent;
  Color _soleColor = Colors.white;
  Color _laceColor = Colors.orange;

  String _meshName = 'Crimson Red';
  String _soleName = 'Arctic White';
  String _laceName = 'Neon Orange';

  final List<Map<String, dynamic>> _meshOptions = [
    {'name': 'Crimson Red', 'color': Colors.redAccent},
    {'name': 'Space Blue', 'color': Colors.blue},
    {'name': 'Forest Green', 'color': Colors.green},
  ];

  final List<Map<String, dynamic>> _soleOptions = [
    {'name': 'Arctic White', 'color': Colors.white},
    {'name': 'Jet Black', 'color': Colors.black87},
    {'name': 'Volt Yellow', 'color': Colors.yellowAccent},
  ];

  final List<Map<String, dynamic>> _laceOptions = [
    {'name': 'Neon Orange', 'color': Colors.orange},
    {'name': 'Cool White', 'color': Colors.white70},
    {'name': 'Volt Green', 'color': Colors.greenAccent},
  ];

  void _saveDesignToCart() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    // Generate custom product variant
    final customProduct = Product(
      id: 'custom_shoe_${DateTime.now().millisecond}',
      name: 'Custom Swift-Run Nitro Shoes',
      brand: 'SHOPVERSE DESIGNER',
      description: 'Mesh: $_meshName, Sole: $_soleName, Laces: $_laceName',
      price: 150.0,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
      category: 'Footwear',
    );

    cart.addItem(customProduct);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved Design! Added $_meshName / $_soleName to bag.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Design Custom Variant', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: Column(
        children: [
          // Visual Shoe Canvas Render Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2F) : Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Base Shoe Icon Mannequin Vector
                  Icon(
                    Icons.directions_run_outlined,
                    size: 200,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),

                  // Customized details representation cards
                  Positioned(
                    top: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141424) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.palette_outlined, color: Colors.blueAccent, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Active Style: $_meshName mesh + $_soleName sole',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Rendering layered color panels representing sneaker parts
                  Positioned(
                    bottom: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildColorComponentBox('Upper Mesh', _meshColor),
                        const SizedBox(width: 12),
                        _buildColorComponentBox('Outsole', _soleColor),
                        const SizedBox(width: 12),
                        _buildColorComponentBox('Laces', _laceColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Customizer Panel controls
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSelectorRow('Sneaker Upper Mesh', _meshOptions, _meshColor, (name, color) {
                  setState(() {
                    _meshName = name;
                    _meshColor = color;
                  });
                }),
                const SizedBox(height: 16),
                _buildSelectorRow('Bottom Rubber Sole', _soleOptions, _soleColor, (name, color) {
                  setState(() {
                    _soleName = name;
                    _soleColor = color;
                  });
                }),
                const SizedBox(height: 16),
                _buildSelectorRow('Shoelaces Color', _laceOptions, _laceColor, (name, color) {
                  setState(() {
                    _laceName = name;
                    _laceColor = color;
                  });
                }),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'ADD DESIGN TO BAG',
                    onPressed: _saveDesignToCart,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorComponentBox(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black38),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSelectorRow(String label, List<Map<String, dynamic>> options, Color activeColor, Function(String, Color) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: options.map((opt) {
            final color = opt['color'] as Color;
            final name = opt['name'] as String;
            final isSelected = color == activeColor;

            return GestureDetector(
              onTap: () => onSelect(name, color),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blueAccent : Colors.grey,
                    width: isSelected ? 2.5 : 1.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
