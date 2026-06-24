import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/screens/checkout/checkout_screen.dart';
import 'package:shopverse/providers/location_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/utils/app_colors.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const _primary = AppColors.primary;
  static const _bg = AppColors.backgroundColor;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context, cart),
      body: cart.itemCount == 0
          ? _buildEmptyCart(context)
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDeliveryBanner(),
                      _buildSectionLabel('YOUR ITEMS', Icons.shopping_bag_outlined, cart.itemCount),
                      _buildCartItemsList(cartItems, cart),
                      _buildFreeDeliveryProgress(cart),
                      _buildSectionLabel('FREQUENTLY BOUGHT', Icons.stars_outlined, null),
                      _buildFrequentlyBoughtTogether(),
                      _buildCouponBanner(),
                      _buildSectionLabel('BILL SUMMARY', Icons.receipt_long_outlined, null),
                      _buildBillDetails(cart),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildPaymentBar(context, cart),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CartProvider cart) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Cart',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
          if (cart.itemCount > 0)
            Text(
              '${cart.itemCount} ${cart.itemCount == 1 ? "item" : "items"}',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
            ),
        ],
      ),
      actions: [
        if (cart.itemCount > 0)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textPrimary, size: 20),
              onPressed: () => cart.clear(),
              tooltip: 'Clear cart',
            ),
          ),
      ],
    );
  }

  Widget _buildDeliveryBanner() {
    return Consumer<LocationProvider>(
      builder: (context, provider, _) {
        final address = provider.selectedAddress;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B61F4), Color(0xFF7C3AED)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery in ${address.deliveryTimeMinutes} mins ⚡',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${address.label} · ${address.addressLine}',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Change',
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String title, IconData icon, int? count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(color: _primary, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFreeDeliveryProgress(CartProvider cart) {
    const freeAt = 499.0;
    final progress = (cart.totalAmount / freeAt).clamp(0.0, 1.0);
    final remaining = (freeAt - cart.totalAmount).clamp(0.0, freeAt);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.accentGreen),
              const SizedBox(width: 6),
              Text(
                progress >= 1.0
                    ? '🎉 You get FREE delivery on this order!'
                    : 'Add ₹${remaining.toInt()} more for FREE delivery',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: progress >= 1.0 ? AppColors.accentGreen : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: _bg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(List cartItems, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cartItems.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100], indent: 80),
        itemBuilder: (context, index) {
          final item = cartItems[index];
          final saving = item.product.oldPrice > item.product.price
              ? ((item.product.oldPrice - item.product.price) * item.quantity)
              : 0.0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: CachedNetworkImage(
                        imageUrl: item.product.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
                        ),
                        errorWidget: (_, __, ___) => const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(item.product.unit, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${item.product.price.toInt()}',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
                          ),
                          if (item.product.oldPrice > item.product.price) ...[
                            const SizedBox(width: 6),
                            Text(
                              '₹${item.product.oldPrice.toInt()}',
                              style: GoogleFonts.inter(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (saving > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Save ₹${saving.toInt()}',
                                style: GoogleFonts.inter(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 9),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Qty stepper
                _CartQtySelector(product: item.product, quantity: item.quantity, cart: cart),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.confirmation_number_outlined, color: _primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apply Coupon', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                Text('Save more with promo codes', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildFrequentlyBoughtTogether() {
    final suggestions = [
      {'name': 'Noise-Cancel Buds', 'price': 89, 'img': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400'},
      {'name': 'Premium Case', 'price': 25, 'img': 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400'},
      {'name': 'Cable & Charger', 'price': 19, 'img': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'},
    ];

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, i) {
          final s = suggestions[i];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Container(
                    height: 110,
                    color: _bg,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: s['img']! as String,
                        height: 90,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2, color: _primary),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['name']! as String, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₹${s['price']}', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 13, color: _primary)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
                            child: Text('+ ADD', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillDetails(CartProvider cart) {
    final itemTotal = cart.totalAmount;
    const deliveryFee = 25.0;
    const handlingFee = 5.0;
    const discount = 0.0;
    final total = itemTotal + deliveryFee + handlingFee - discount;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _billRow('Item Total', '₹${itemTotal.toStringAsFixed(2)}'),
          _billRow('Delivery Fee', '₹${deliveryFee.toStringAsFixed(2)}', iconData: Icons.local_shipping_outlined),
          _billRow('Handling Charge', '₹${handlingFee.toStringAsFixed(2)}', iconData: Icons.handshake_outlined),
          if (discount > 0)
            _billRow('Discount', '-₹${discount.toStringAsFixed(2)}', isGreen: true, iconData: Icons.confirmation_number_outlined),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Colors.grey[100], thickness: 1.5),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary.withValues(alpha: 0.06), _primary.withValues(alpha: 0.02)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grand Total', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 22, color: _primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.savings_outlined, size: 14, color: AppColors.accentGreen),
                const SizedBox(width: 6),
                Text(
                  'You save ₹5.00 with free delivery promo',
                  style: GoogleFonts.inter(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isGreen = false, IconData? iconData}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (iconData != null) ...[
            Icon(iconData, size: 14, color: isGreen ? AppColors.accentGreen : AppColors.textMuted),
            const SizedBox(width: 6),
          ],
          Text(label, style: GoogleFonts.inter(color: isGreen ? AppColors.accentGreen : AppColors.textMuted, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: isGreen ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              color: isGreen ? AppColors.accentGreen : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 56, color: _primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Looks like you haven\'t added\nanything yet. Let\'s change that!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Browse Products',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBar(BuildContext context, CartProvider cart) {
    final total = cart.totalAmount + 25 + 5;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
              Text(
                '₹${total.toInt()}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textPrimary),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View bill details',
                  style: GoogleFonts.inter(color: _primary, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Proceed to Pay',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Quantity Stepper ────────────────────────────────────────────────────
class _CartQtySelector extends StatelessWidget {
  final Product product;
  final int quantity;
  final CartProvider cart;

  const _CartQtySelector({required this.product, required this.quantity, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => cart.removeSingleItem(product.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: const Icon(Icons.remove_rounded, color: Colors.white, size: 16),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 24),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          GestureDetector(
            onTap: () => cart.addItem(product),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
