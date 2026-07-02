import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class ReceiptScreen extends StatelessWidget {
  final String orderId;
  final double totalAmount;

  const ReceiptScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.grey[200],
      appBar: AppBar(
        title: const Text('Digital Invoice', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              // Zig-zag receipt container
              ClipPath(
                clipper: _ZigZagClipper(),
                child: Container(
                  width: double.infinity,
                  color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      // Header details
                      const Text(
                        'SHOPVERSE INVOICE',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 4),
                      const Text('Thank you for shopping with us!', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Order meta rows
                      _buildReceiptRow('Order ID:', orderId.substring(0, 12)),
                      _buildReceiptRow('Date:', 'July 2, 2026'),
                      _buildReceiptRow('Payment Method:', 'ShopVerse Wallet'),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Items list block
                      _buildReceiptRow('1x Amul Taaza Milk', '₹27'),
                      _buildReceiptRow('1x Fortune Sunflower Oil', '₹145'),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Billing Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL AMOUNT:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          Text(
                            '₹${totalAmount.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.brandRed),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Barcode simulation
                      const Text('SCAN FOR RECEIPT STATUS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      _buildMockBarcode(),
                      const SizedBox(height: 32),

                      // Split QR Code card
                      const Text('SPLIT BILL SHARE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                        ),
                        child: _buildQrMatrix(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'SHARE INVOICE QR',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Split receipt link shared!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMockBarcode() {
    // Generate a set of dynamic thin and thick vertical barcode lines
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(35, (index) {
        final double width = (index % 3 == 0) ? 3.0 : 1.2;
        final double spacing = (index % 4 == 0) ? 2.0 : 1.0;
        return Container(
          width: width,
          height: 36,
          margin: EdgeInsets.only(right: spacing),
          color: Colors.black,
        );
      }),
    );
  }

  Widget _buildQrMatrix() {
    // Draw a mock QR code layout using grids
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: 49,
      itemBuilder: (context, index) {
        // Mock a QR layout with solid corners
        bool isBlack = false;
        
        // Top-left corner
        if (index < 3 || (index >= 7 && index < 10) || (index >= 14 && index < 17)) isBlack = true;
        // Top-right corner
        if (index >= 4 && index < 7 || (index >= 11 && index < 14) || (index >= 18 && index < 21)) isBlack = true;
        // Bottom-left corner
        if (index >= 35 && index < 38 || (index >= 42 && index < 45)) isBlack = true;
        // Random dots inside
        if (index % 5 == 0 && index > 21 && index < 35) isBlack = true;

        return Container(
          color: isBlack ? Colors.black : Colors.white,
        );
      },
    );
  }
}

class _ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    
    // Zig-zag cut at top edge
    double factor = 8.0;
    for (double i = 0; i < size.width; i += factor * 2) {
      path.lineTo(i + factor, factor);
      path.lineTo(i + factor * 2, 0);
    }
    
    path.lineTo(size.width, size.height);
    
    // Zig-zag cut at bottom edge
    for (double i = size.width; i > 0; i -= factor * 2) {
      path.lineTo(i - factor, size.height - factor);
      path.lineTo(i - factor * 2, size.height);
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
