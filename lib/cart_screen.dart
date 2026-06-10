import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/location_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/providers/order_provider.dart';
import 'providers/cart_provider.dart';
import 'models/product.dart';
import 'tracking_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();
    const Color brandRed = Color(0xFFFF3232);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
      ),
      body: cart.itemCount == 0
          ? _buildEmptyCart(context, brandRed)
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeliveryInfo(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('Items in cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: brandRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text('${cart.itemCount}', style: const TextStyle(color: brandRed, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  _buildCartItemsList(cartItems, cart, brandRed),
                  _buildFrequentlyBoughtTogether(),
                  _buildBillDetails(cart, brandRed),
                  const SizedBox(height: 120),
                ],
              ),
            ),
      bottomSheet: cart.itemCount == 0 ? null : _buildPaymentBar(context, cart, brandRed),
    );
  }

  Widget _buildDeliveryInfo() {
    return Consumer<LocationProvider>(
      builder: (context, provider, _) {
        final address = provider.selectedAddress;
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.timer, color: Color(0xFFFF3232), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery in ${address.deliveryTimeMinutes} mins', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('${address.label}: ${address.addressLine}', style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {}, // Handled by header in home for now
                child: const Text('CHANGE', style: TextStyle(color: Color(0xFFFF3232), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context, Color themeColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add items to get started', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(List cartItems, CartProvider cart, Color themeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cartItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
                  child: CachedNetworkImage(
                    imageUrl: item.product.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(item.product.unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('₹${item.product.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    ],
                  ),
                ),
                _CartQtySelector(product: item.product, quantity: item.quantity, cart: cart, themeColor: themeColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrequentlyBoughtTogether() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text('Frequently Bought Together', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        SizedBox(
          height: 240,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSimpleProductCard('Noise-Cancel Buds', 89, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800'),
              _buildSimpleProductCard('Premium Case', 25, 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=800'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleProductCard(String name, int price, String img) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(imageUrl: img, height: 160, width: 160, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1),
                Text('₹$price', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFFF3232))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetails(CartProvider cart, Color themeColor) {
    double itemTotal = cart.totalAmount;
    double deliveryFee = 25.0; // Fixed delivery fee for mock
    double handlingFee = 5.0;
    double total = itemTotal + deliveryFee + handlingFee;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bill Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 16),
          _billRow('Item Total', '₹${itemTotal.toInt()}'),
          _billRow('Delivery Fee', '₹${deliveryFee.toInt()}', color: const Color(0xFF00796B)),
          _billRow('Handling Charge', '₹${handlingFee.toInt()}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              Text('₹${total.toInt()}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: themeColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildPaymentBar(BuildContext context, CartProvider cart, Color themeColor) {
    double total = cart.totalAmount + 25 + 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${total.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                const Text('VIEW DETAILED BILL', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showOrderSuccess(context, cart, themeColor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Proceed to Pay', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderSuccess(BuildContext context, CartProvider cart, Color themeColor) {
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    final total = cart.totalAmount + 25 + 5;
    orderProv.addOrder(total, cart.items.values.toList());

    cart.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text('Order Placed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Arriving in 10 minutes', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const TrackingScreen(orderId: 'ORD-5521')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                  child: const Text('TRACK ORDER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartQtySelector extends StatelessWidget {
  final Product product;
  final int quantity;
  final CartProvider cart;
  final Color themeColor;

  const _CartQtySelector({required this.product, required this.quantity, required this.cart, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => cart.removeSingleItem(product.id),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          GestureDetector(
            onTap: () => cart.addItem(product),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
