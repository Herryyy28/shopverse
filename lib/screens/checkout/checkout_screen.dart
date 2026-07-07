import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/location_provider.dart';
import 'package:shopverse/providers/wallet_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:shopverse/providers/order_provider.dart';
import 'package:shopverse/screens/checkout/tracking_screen.dart';
import 'package:shopverse/screens/checkout/location_picker_screen.dart';
import 'package:shopverse/screens/checkout/receipt_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0: Wallet, 1: UPI, 2: Card, 3: Cash
  static const Color _primary = Color(0xFF5B61F4);
  bool _isProcessing = false;
  bool _carbonNeutral = false;
  bool _ecoCargo = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final locationProv = Provider.of<LocationProvider>(context);
    final walletProv = Provider.of<WalletProvider>(context);
    final address = locationProv.selectedAddress;

    const double deliveryFee = 5.0;
    const double handlingFee = 2.0;
    final double taxes = cart.totalAmount * 0.05;
    const double couponDiscount = 15.0;
    const double pointsRedeemed = 10.0;

    final totalAmount = cart.totalAmount + deliveryFee + handlingFee + taxes - couponDiscount - pointsRedeemed;
    final totalSavings = couponDiscount + pointsRedeemed + 5.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A2E), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkout',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              'Review your order',
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFF5B61F4)),
            onPressed: () => _startVoiceCheckout(context),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.help_outline, color: Color(0xFF1A1A2E)),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Section
            _buildSectionHeader('DELIVERY ADDRESS', Icons.location_on_outlined),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.home_outlined, color: _primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('DEFAULT', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () async {
                                final selectedLoc = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
                                );
                                if (selectedLoc != null) {
                                  final parts = selectedLoc.split(',');
                                  final line = parts.isNotEmpty ? parts[0] : selectedLoc;
                                  final area = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
                                  locationProv.addAddress('Custom Pin', line, area);
                                }
                              },
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${address.addressLine}, ${address.area}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange, size: 14),
                            Text(
                              ' Delivery in ${address.deliveryTimeMinutes} mins',
                              style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Order Summary Section
            _buildSectionHeader('ORDER SUMMARY', Icons.shopping_bag_outlined),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.items.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final item = cart.items.values.toList()[index];
                  return Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F7FB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: item.product.imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.product.unit,
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${item.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E), fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'x${item.quantity}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bill Breakdown Section
            _buildSectionHeader('BILL BREAKDOWN', Icons.receipt_long_outlined),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildBillRow('Item Total', '₹${cart.totalAmount.toStringAsFixed(2)}'),
                  _buildBillRow('Delivery Fee', '₹${deliveryFee.toStringAsFixed(2)}'),
                  _buildBillRow('Handling Fee', '₹${handlingFee.toStringAsFixed(2)}'),
                  _buildBillRow('Taxes & Charges', '₹${taxes.toStringAsFixed(2)}'),
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey[100], thickness: 1),
                  const SizedBox(height: 8),
                  _buildBillRow(
                    'Coupon (SVFIRST)',
                    '-₹${couponDiscount.toStringAsFixed(2)}',
                    isDiscount: true,
                    icon: Icons.confirmation_number_outlined,
                  ),
                  _buildBillRow(
                    'Points Redeemed',
                    '-₹${pointsRedeemed.toStringAsFixed(2)}',
                    isDiscount: true,
                    icon: Icons.stars_outlined,
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey[100], thickness: 1),
                  const SizedBox(height: 12),
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
                        const Text(
                          'Total Amount',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A2E)),
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.savings_outlined, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          'You save ₹${totalSavings.toStringAsFixed(2)} on this order 🎉',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Carbon-Neutral delivery choice
            _buildSectionHeader('GREEN DELIVERY', Icons.eco_outlined),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.park_outlined, color: Colors.green, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Carbon-Neutral Delivery',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Deliver in grouped cycles. Earn +15 Coins!',
                          style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _carbonNeutral,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        _carbonNeutral = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, color: Colors.green, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Eco-Cargo Route Grouping',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Slower fleet logistics path. Earn +25 Coins!',
                          style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _ecoCargo,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        _ecoCargo = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Payment Method Section
            _buildSectionHeader('PAYMENT METHOD', Icons.payment_outlined),
            _buildPaymentOption(
              index: 0,
              icon: Icons.account_balance_wallet_outlined,
              title: 'ShopVerse Wallet',
              subtitle: 'Balance: ₹${walletProv.balance.toStringAsFixed(2)}',
              isEnabled: walletProv.balance >= totalAmount,
            ),
            _buildPaymentOption(
              index: 1,
              icon: Icons.account_balance_outlined,
              title: 'UPI',
              subtitle: 'Google Pay, PhonePe, Paytm',
            ),
            _buildPaymentOption(
              index: 2,
              icon: Icons.credit_card_outlined,
              title: 'Credit / Debit Card',
              subtitle: 'Visa, Mastercard, RuPay',
            ),
            _buildPaymentOption(
              index: 3,
              icon: Icons.money_outlined,
              title: 'Cash on Delivery',
              subtitle: 'Pay at your doorstep',
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isProcessing
                    ? null
                    : () => _handlePayment(context, totalAmount, cart, walletProv),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: _isProcessing
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF5B61F4), Color(0xFF8B5CF6)],
                            ),
                      color: _isProcessing ? Colors.grey[300] : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isProcessing
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline, size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Proceed to Pay',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
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

  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isEnabled = true,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: isEnabled ? () => setState(() => _selectedPaymentMethod = index) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                ? _primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 15 : 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                  ? _primary.withValues(alpha: 0.12)
                  : const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? _primary : Colors.grey[500],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isEnabled ? const Color(0xFF1A1A2E) : Colors.grey,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!isEnabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Low Balance', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? _primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _primary : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isDiscount = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: isDiscount ? Colors.green : Colors.grey[600]),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: isDiscount ? Colors.green : Colors.grey[600],
              fontSize: 14,
              fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? Colors.green : const Color(0xFF1A1A2E),
              fontSize: 14,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context, double total, CartProvider cart, WalletProvider wallet) async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    if (_selectedPaymentMethod == 0) {
      if (wallet.balance >= total) {
        wallet.pay(total, 'ORD-${DateTime.now().millisecond}');
      } else {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient Wallet Balance')),
        );
        return;
      }
    }

    if (_carbonNeutral) {
      wallet.addCoins(15, 'Carbon Neutral Delivery Reward');
    }

    if (_ecoCargo) {
      wallet.addCoins(25, 'Eco-Cargo Logistics Reward');
    }

    if (!context.mounted) return;
    _showSuccessDialog(context, total, cart, _selectedPaymentMethod);
    setState(() => _isProcessing = false);
  }

  void _showSuccessDialog(BuildContext context, double total, CartProvider cart, int paymentMethodIndex) async {
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    final locationProv = Provider.of<LocationProvider>(context, listen: false);
    final couponProv = Provider.of<CouponProvider>(context, listen: false);
    
    final paymentMethods = ['ShopVerse Wallet', 'UPI', 'Credit / Debit Card', 'Cash on Delivery'];
    
    final orderId = await orderProv.addOrder(
      items: cart.items.values.toList(),
      totalAmount: total,
      deliveryFee: 25.0, // Assuming static for now or fetch from logic
      tax: cart.totalAmount * 0.05,
      discount: couponProv.getDiscount(cart.totalAmount),
      deliveryAddress: '${locationProv.selectedAddress.addressLine}, ${locationProv.selectedAddress.area}',
      paymentMethod: paymentMethods[paymentMethodIndex],
    );
    
    cart.clear();
    couponProv.applyCoupon(null);
    
    final shortId = orderId;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        _confettiController.play();
        return Stack(
          alignment: Alignment.center,
          children: [
            AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B61F4), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(45),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Placed! 🎉',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 10),
            Text(
              'Your order $shortId has been placed successfully. Track it in the orders section.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TrackingScreen(orderId: shortId)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B61F4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Track Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiptScreen(
                        orderId: orderId,
                        totalAmount: total,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5B61F4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('View Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF5B61F4))),
              ),
            ),
          ],
        ),
      ),
      ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
        numberOfParticles: 50,
        maxBlastForce: 100,
        minBlastForce: 80,
        gravity: 0.2,
      ),
    ],
  );
},
);
  }
  void _startVoiceCheckout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return _VoiceCheckoutAssistantDialog(
          onConfirmed: (bool useWallet, bool useEco, bool useEcoCargo) {
            setState(() {
              if (useWallet) _selectedPaymentMethod = 0;
              if (useEco) _carbonNeutral = true;
              if (useEcoCargo) _ecoCargo = true;
            });
          },
        );
      },
    );
  }
}

class _VoiceCheckoutAssistantDialog extends StatefulWidget {
  final Function(bool, bool, bool) onConfirmed;

  const _VoiceCheckoutAssistantDialog({required this.onConfirmed});

  @override
  State<_VoiceCheckoutAssistantDialog> createState() => _VoiceCheckoutAssistantDialogState();
}

class _VoiceCheckoutAssistantDialogState extends State<_VoiceCheckoutAssistantDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _statusText = 'Say: "pay using wallet and select eco-friendly options"';
  bool _listening = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _statusText = 'Heard: "pay with wallet and use green delivery routes"';
        });
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _statusText = 'Applying voice commands...';
          _listening = false;
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            widget.onConfirmed(true, true, true);
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'VOICE CHECKOUT ASSISTANT',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 32,
              backgroundColor: _listening ? Colors.blueAccent : Colors.green,
              child: Icon(_listening ? Icons.mic : Icons.check, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 20),
            if (_listening)
              SizedBox(
                height: 40,
                width: 180,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _SiriWavePainter(value: _animationController.value),
                    );
                  },
                ),
              )
            else
              const SizedBox(height: 40),
            const SizedBox(height: 20),
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SiriWavePainter extends CustomPainter {
  final double value;
  _SiriWavePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paint2 = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path1 = Path();
    final path2 = Path();

    path1.moveTo(0, size.height / 2);
    path2.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final y1 = size.height / 2 + sin((x / size.width * 2 * pi * 2) + value * 2 * pi) * 12 * sin(value * pi);
      final y2 = size.height / 2 + cos((x / size.width * 2 * pi * 3) - value * 2 * pi) * 8 * sin(value * pi);
      path1.lineTo(x, y1);
      path2.lineTo(x, y2);
    }

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _SiriWavePainter oldDelegate) => true;
}
