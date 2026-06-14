class OrderItem {
  final String id;
  final double amount;
  final List<dynamic> products;
  final DateTime dateTime;
  final String status;
  final String userId;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
    required this.userId,
    this.status = 'Pending',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'products': products,
    'dateTime': dateTime.toIso8601String(),
    'status': status,
    'userId': userId,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    products: json['products'] ?? [],
    dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
    status: json['status'] ?? 'Pending',
    userId: json['userId'] ?? '',
  );
}
