import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentCheckoutService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      // Set the Stripe publishable key
      Stripe.publishableKey = "pk_test_51MockPublishableKeyShopVerse";
      await Stripe.instance.applySettings();
      _isInitialized = true;
      debugPrint('Stripe initialized successfully');
    } catch (e) {
      debugPrint('Stripe initialization failed: $e');
    }
  }

  static Future<bool> startCardPayment({
    required BuildContext context,
    required double amount,
    required String currency,
  }) async {
    try {
      await initialize();
      
      if (!context.mounted) return false;

      // Check if we are running in a mock environment
      if (Stripe.publishableKey.contains("Mock")) {
        return await _showSimulatedPaymentDialog(context, amount, currency);
      }

      // Simulate client secret generation from your backend API gateway
      const mockClientSecret = "pi_mock_intent_secret";

      // Initialize the Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: const SetupPaymentSheetParameters(
          paymentIntentClientSecret: mockClientSecret,
          merchantDisplayName: 'ShopVerse Inc.',
          style: ThemeMode.light,
        ),
      );

      // Present the Payment Sheet UI
      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      debugPrint('Stripe checkout error: $e');
      // If Stripe sheet errors (e.g. mock secret validation), fall back gracefully
      return false;
    }
  }

  static Future<bool> _showSimulatedPaymentDialog(
    BuildContext context,
    double amount,
    String currency,
  ) async {
    bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.payment_outlined, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text(
                  'Stripe Checkout (Demo)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'A standard Stripe payment sheet is simulated for testing. Click the button below to confirm a successful test transaction.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Merchant', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('ShopVerse Inc.', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Amount to Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${currency.toUpperCase()} ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('PAY SECURELY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('CANCEL', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    return result ?? false;
  }
}
