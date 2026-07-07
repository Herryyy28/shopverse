import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/order_provider.dart';
import 'package:shopverse/screens/checkout/tracking_screen.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  const PaymentScreen({super.key, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'upi';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isProcessing ? _buildProcessing() : _buildPaymentMethods(),
      bottomNavigationBar: _isProcessing ? null : _buildPayButton(),
    );
  }

  Widget _buildProcessing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.brandRed),
          const SizedBox(height: 24),
          const Text('Processing your payment...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Do not press back or close the app', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brandRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: AppColors.brandRed),
                const SizedBox(width: 12),
                const Text('Amount to Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('₹${widget.amount.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.brandRed)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('RECOMMENDED', style: TextStyle(letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _methodTile('upi', 'Google Pay / PhonePe', Icons.account_balance, subtitle: 'Pay via any UPI app'),
          const SizedBox(height: 24),
          const Text('OTHER METHODS', style: TextStyle(letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _methodTile('card', 'Credit / Debit Cards', Icons.credit_card, subtitle: 'Save cards for faster checkout'),
          _methodTile('netbanking', 'Net Banking', Icons.house, subtitle: 'All major banks supported'),
          _methodTile('cod', 'Cash on Delivery', Icons.money, subtitle: 'Pay when order arrives'),
        ],
      ),
    );
  }

  Widget _methodTile(String id, String title, IconData icon, {String? subtitle}) {
    bool isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.brandRed : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.brandRed : AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (subtitle != null) Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedMethod,
              activeColor: AppColors.brandRed,
              onChanged: (val) => setState(() => _selectedMethod = val!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: CustomButton(
          text: 'PAY ₹${widget.amount.toInt()}',
          onPressed: _processPayment,
        ),
      ),
    );
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    
    final orderId = await orderProv.addOrder(
      items: cart.items.values.toList(),
      totalAmount: widget.amount,
      deliveryFee: 0.0,
      tax: 0.0,
      discount: 0.0,
      deliveryAddress: 'Default Address',
      paymentMethod: _selectedMethod.toUpperCase(),
    );
    
    cart.clear();

    if (!context.mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TrackingScreen(orderId: orderId)),
    );
  }
}
