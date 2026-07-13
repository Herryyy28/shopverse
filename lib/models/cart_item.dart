import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: (json['product'] is Map)
          ? Product.fromJson(Map<String, dynamic>.from(json['product']))
          : Product(
              id: '',
              name: 'Unknown Product',
              description: '',
              price: 0,
              imageUrl: '',
              category: '',
            ),
      quantity: json['quantity'] ?? 1,
    );
  }
}
