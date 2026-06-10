import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'providers/cart_provider.dart';
import 'models/product.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
      ),
      body: cart.itemCount == 0
          ? _buildEmptyCart(context)
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildDeliveryTimeCard(),
                  _buildCartItemsList(cartItems, cart),
                  _buildBillDetails(cart),
                  _buildSafetyPledge(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
      bottomSheet: cart.itemCount == 0 ? null : _buildPaymentBar(context, cart),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3232)),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.timer_outlined, color: Colors.green),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery in 8 minutes', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text('Shipment 1 of 1', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(List cartItems, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cartItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item.product.imageUrl,
                    width: 60,
                    height: 60,
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
                      Text('₹${item.product.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                _CartQtySelector(product: item.product, quantity: item.quantity, cart: cart),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillDetails(CartProvider cart) {
    double itemTotal = cart.totalAmount;
    double deliveryFee = 25.0;
    double handlingFee = 5.0;
    double total = itemTotal + deliveryFee + handlingFee;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bill Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 16),
          _billRow(Icons.article_outlined, 'Item Total', '₹${itemTotal.toInt()}'),
          _billRow(Icons.delivery_dining_outlined, 'Delivery Fee', '₹${deliveryFee.toInt()}'),
          _billRow(Icons.shopping_bag_outlined, 'Handling Charge', '₹${handlingFee.toInt()}'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text('₹${total.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSafetyPledge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.2))),
      child: const Row(
        children: [
          Icon(Icons.security, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text('Our delivery partner will follow all safety protocols', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildPaymentBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: InkWell(
          onTap: () => _showOrderSuccess(context, cart),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3232),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('₹${(cart.totalAmount + 30).toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    const Text('TOTAL', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                const Text('Place Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_right_alt, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderSuccess(BuildContext context, CartProvider cart) {
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
              const Text('Arriving in 8 minutes', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back home
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3232)),
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

  const _CartQtySelector({required this.product, required this.quantity, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFF3232),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.remove, color: Colors.white, size: 16),
            onPressed: () => cart.removeSingleItem(product.id),
          ),
          Text('$quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          IconButton(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            onPressed: () => cart.addItem(product),
          ),
        ],
      ),
    );
  }
}
