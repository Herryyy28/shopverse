import 'cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned
}

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final double deliveryFee;
  final double tax;
  final double discount;
  final String deliveryAddress;
  final OrderStatus status;
  final String paymentMethod;
  final DateTime createdAt;
  final String? trackingId;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.deliveryFee = 0.0,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.deliveryAddress,
    this.status = OrderStatus.pending,
    required this.paymentMethod,
    required this.createdAt,
    this.trackingId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((x) => x.toJson()).toList(),
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'discount': discount,
      'deliveryAddress': deliveryAddress,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'trackingId': trackingId,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] is List)
          ? (json['items'] as List)
              .whereType<Map>()
              .map((x) => CartItem.fromJson(Map<String, dynamic>.from(x)))
              .toList()
          : [],
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      deliveryAddress: json['deliveryAddress'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: json['paymentMethod'] ?? '',
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt']) ?? DateTime.now())
          : DateTime.now(),
      trackingId: json['trackingId'],
    );
  }
}
