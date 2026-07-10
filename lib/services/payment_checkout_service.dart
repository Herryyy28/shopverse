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
}
