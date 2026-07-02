import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  final TextEditingController _mockController = TextEditingController();

  bool get _isDesktop {
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  @override
  void dispose() {
    _mockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      appBar: AppBar(
        title: const Text('Scan Barcode', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: !_isDesktop,
      body: _isDesktop ? _buildDesktopSimulator(isDark) : _buildMobileScanner(),
    );
  }

  Widget _buildMobileScanner() {
    return MobileScanner(
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        if (barcodes.isNotEmpty) {
          final String? code = barcodes.first.rawValue;
          if (code != null) {
            Navigator.pop(context, code);
          }
        }
      },
    );
  }

  Widget _buildDesktopSimulator(bool isDark) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(28.0),
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2F) : Colors.grey[50],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scanning viewfinder mockup
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.qr_code_2, color: Colors.white24, size: 100),
                  // Red laser light animation simulator
                  TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 2),
                    tween: Tween(begin: -50.0, end: 50.0),
                    onEnd: () {}, // Handled by standard loop or repeat
                    builder: (context, val, child) {
                      return Transform.translate(
                        offset: Offset(0, val),
                        child: Container(
                          width: double.infinity,
                          height: 2,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            boxShadow: [
                              BoxShadow(color: Colors.redAccent, blurRadius: 8, spreadRadius: 1),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Barcode Simulator',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Running in Desktop Mode. Select a mock item below to simulate a successful scan:',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            
            // Simulated products shortcuts
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMockChip('Taaza Milk', 'p1'),
                _buildMockChip('Headphones', 'p0'),
                _buildMockChip('Chronos Watch', 'p00'),
                _buildMockChip('Swift Shoes', 'p000'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            TextField(
              controller: _mockController,
              decoration: const InputDecoration(
                hintText: 'Or enter custom barcode ID...',
                prefixIcon: Icon(Icons.keyboard),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'SIMULATE SCAN',
                    onPressed: () {
                      if (_mockController.text.isNotEmpty) {
                        Navigator.pop(context, _mockController.text.trim());
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockChip(String label, String code) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.primaryLight,
      onPressed: () => Navigator.pop(context, code),
    );
  }
}
