import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/location_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:shopverse/providers/order_provider.dart';
import 'package:shopverse/tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0: Wallet, 1: UPI, 2: Card, 3: Cash
  final Color brandRed = const Color(0xFFFF3232);
  bool _isProcessing = false;

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
    final totalSavings = couponDiscount + pointsRedeemed + 5.0; // Mocking some additional savings

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bill Details',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Section
            _buildSectionHeader('DELIVERY ADDRESS'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onPressed: () {
                                // Navigator to address selection or show bottom sheet
                              },
                              child: Text(
                                'Change',
                                style: TextStyle(
                                  color: brandRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${address.addressLine}, ${address.area}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Order Summary Section
            _buildSectionHeader('ORDER SUMMARY'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.items.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final item = cart.items.values.toList()[index];
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: item.product.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.product.unit,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${item.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'x${item.quantity}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bill Breakdown Section
            _buildSectionHeader('BILL BREAKDOWN'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildBillRow('Item Total', '₹${cart.totalAmount.toStringAsFixed(2)}'),
                  _buildBillRow('Delivery Fee', '₹${deliveryFee.toStringAsFixed(2)}'),
                  _buildBillRow('Handling Fee', '₹${handlingFee.toStringAsFixed(2)}'),
                  _buildBillRow('Taxes & Charges', '₹${taxes.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  const Divider(thickness: 1, height: 1),
                  const SizedBox(height: 12),
                  _buildBillRow(
                    'Coupon (SVFIRST)', 
                    '-₹${couponDiscount.toStringAsFixed(2)}', 
                    isDiscount: true,
                    icon: Icons.confirmation_number_outlined,
                  ),
                  _buildBillRow(
                    'Points Redeemed (500 pts)', 
                    '-₹${pointsRedeemed.toStringAsFixed(2)}', 
                    isDiscount: true,
                    icon: Icons.stars_outlined,
                  ),
                  const SizedBox(height: 12),
                  const Divider(thickness: 1, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '₹${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 20, 
                          color: brandRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Payment Method Section
            _buildSectionHeader('PAYMENT METHOD'),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.savings_outlined, size: 14, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text(
                          'Save ₹${totalSavings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing 
                        ? null 
                        : () => _handlePayment(context, totalAmount, cart, walletProv),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        disabledBackgroundColor: brandRed.withValues(alpha: 0.5),
                      ),
                      child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Proceed to Pay',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                    ),
                  ),
                ],
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
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? brandRed : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: brandRed.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isSelected ? brandRed : Colors.grey[100])?.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon, 
                color: isSelected ? brandRed : Colors.grey[600],
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
                      color: isEnabled ? Colors.black : Colors.grey,
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
              Text(
                'Insufficient',
                style: TextStyle(color: brandRed, fontSize: 10, fontWeight: FontWeight.bold),
              )
            else
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_off,
                color: isSelected ? brandRed : Colors.grey[300],
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          if (title == 'DELIVERY ADDRESS')
            Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[700]),
          if (title == 'DELIVERY ADDRESS') const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isDiscount = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isDiscount ? const Color(0xFF2E7D32) : Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: isDiscount ? const Color(0xFF2E7D32) : Colors.grey[700],
              fontSize: 14,
              fontWeight: isDiscount ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? const Color(0xFF2E7D32) : Colors.black,
              fontSize: 14,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }


  void _handlePayment(BuildContext context, double total, CartProvider cart, WalletProvider wallet) async {
    setState(() => _isProcessing = true);

    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_selectedPaymentMethod == 0) { // Wallet
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

    // Success flow
    _showSuccessDialog(context, total, cart.items.values.toList());
    cart.clear();
    setState(() => _isProcessing = false);
  }

  void _showSuccessDialog(BuildContext context, double total, List cartItems) {
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    final orderId = orderProv.addOrder(total, cartItems);
    final shortId = 'ORD-${orderId.substring(orderId.length - 6).toUpperCase()}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Order Placed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your order $shortId has been placed successfully. You can track it in the orders section.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close checkout
                  Navigator.of(context).pop(); // Close cart
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TrackingScreen(orderId: shortId)),
                  );
                },
                child: const Text('Track Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
