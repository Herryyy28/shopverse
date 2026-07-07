import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/coupon_provider.dart';
import 'package:shopverse/models/coupon_model.dart';
import 'package:shopverse/utils/app_colors.dart';

class CouponsScreen extends StatefulWidget {
  final double orderAmount;
  const CouponsScreen({super.key, required this.orderAmount});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _applyCouponCode(CouponProvider provider) {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a coupon code');
      return;
    }
    final error = provider.applyCoupon(code, widget.orderAmount);
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      HapticFeedback.mediumImpact();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponProv = Provider.of<CouponProvider>(context);
    final coupons = couponProv.availableCoupons;
    final bestCoupon = couponProv.getBestCoupon(widget.orderAmount);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Apply Coupon', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Coupon input
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 0),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                      errorText: _errorMessage,
                      prefixIcon: const Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (_) => setState(() => _errorMessage = null),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _applyCouponCode(couponProv),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('APPLY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          // Best coupon banner
          if (bestCoupon != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF009624)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Best Coupon For You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(
                          '${bestCoupon.code} — Save ₹${bestCoupon.calculateDiscount(widget.orderAmount).toInt()}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      couponProv.applyCoupon(bestCoupon.code, widget.orderAmount);
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('APPLY', style: TextStyle(color: Color(0xFF009624), fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),

          // Available coupons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.local_offer_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Text(
                  'AVAILABLE COUPONS (${coupons.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                final discount = coupon.calculateDiscount(widget.orderAmount);
                final isApplicable = widget.orderAmount >= coupon.minOrderAmount;
                final isApplied = couponProv.appliedCoupon?.id == coupon.id;

                return _buildCouponCard(coupon, discount, isApplicable, isApplied, couponProv);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(CouponModel coupon, double discount, bool isApplicable, bool isApplied, CouponProvider provider) {
    final daysLeft = coupon.expiresAt.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isApplied ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Top section with dashed border
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Discount badge
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${coupon.discountPercent.toInt()}%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        const Text('OFF', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              coupon.code,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isApplied)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('APPLIED ✓', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(coupon.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(coupon.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: daysLeft <= 3 ? Colors.red : AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  daysLeft <= 0 ? 'Expires today!' : 'Expires in $daysLeft days',
                  style: TextStyle(
                    fontSize: 11,
                    color: daysLeft <= 3 ? Colors.red : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Min. ₹${coupon.minOrderAmount.toInt()}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const Spacer(),
                if (isApplicable && !isApplied)
                  GestureDetector(
                    onTap: () {
                      provider.applyCoupon(coupon.code, widget.orderAmount);
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'APPLY  — Save ₹${discount.toInt()}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  )
                else if (isApplied)
                  GestureDetector(
                    onTap: () {
                      provider.removeCoupon();
                      Navigator.pop(context, true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('REMOVE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  )
                else
                  Text(
                    'Add ₹${(coupon.minOrderAmount - widget.orderAmount).toInt()} more',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
