import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class ARDimensionCalculator extends StatefulWidget {
  const ARDimensionCalculator({super.key});

  @override
  State<ARDimensionCalculator> createState() => _ARDimensionCalculatorState();
}

class _ARDimensionCalculatorState extends State<ARDimensionCalculator> {
  bool _scanning = false;
  bool _scanned = false;
  String _target = 'Foot'; // 'Foot' or 'Hand'
  
  double _calculatedLength = 0.0;
  String _calculatedSize = '';

  void _triggerScan() async {
    setState(() {
      _scanning = true;
      _scanned = false;
    });

    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      setState(() {
        _scanning = false;
        _scanned = true;
        if (_target == 'Foot') {
          _calculatedLength = 26.5; // cm
          _calculatedSize = 'UK 8.5';
        } else {
          _calculatedLength = 18.2; // cm
          _calculatedSize = 'Medium (Fits size 7.5)';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AR Dimension Sizer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Simulated AR Viewfinder screen
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // view finder camera background container
                Container(
                  color: isDark ? const Color(0xFF0F0F1A) : Colors.grey[900],
                ),

                // Grid/Camera targets template lines
                Container(
                  width: 220,
                  height: 320,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2.0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Calibration guides
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(width: 20, height: 2, color: Colors.blueAccent),
                      ),
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(width: 2, height: 20, color: Colors.blueAccent),
                      ),
                      
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(width: 20, height: 2, color: Colors.blueAccent),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(width: 2, height: 20, color: Colors.blueAccent),
                      ),

                      if (_scanning)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.blueAccent),
                        ),
                    ],
                  ),
                ),

                // Guide Label text
                const Positioned(
                  top: 24,
                  child: Text(
                    'ALIGN CARD & TARGET INSIDE THE FRAME',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Control Panel Dashboard bottom sheet
          Container(
            padding: const EdgeInsets.all(24),
            color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_scanning && !_scanned) ...[
                  // Target choosing row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTargetChip('Foot', Icons.directions_run),
                      const SizedBox(width: 16),
                      _buildTargetChip('Wrist/Hand', Icons.pan_tool_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'MEASURE DIMENSION',
                      onPressed: _triggerScan,
                    ),
                  ),
                ] else if (_scanning) ...[
                  const Text('Computing target dimensions...', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(color: Colors.blueAccent),
                ] else if (_scanned) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Calculated length: $_calculatedLength cm',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Recommended Size: $_calculatedSize',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _scanned = false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('RE-SCAN', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'APPLY SIZE',
                          onPressed: () {
                            Navigator.pop(context, _calculatedSize);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(String label, IconData icon) {
    final active = _target == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      avatar: Icon(icon, size: 14, color: active ? Colors.white : Colors.grey),
      label: Text(label, style: TextStyle(color: active ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold, fontSize: 11)),
      selected: active,
      selectedColor: Colors.blueAccent,
      onSelected: (val) {
        if (val) {
          setState(() {
            _target = label;
          });
        }
      },
    );
  }
}
