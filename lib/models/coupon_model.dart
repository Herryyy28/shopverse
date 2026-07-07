class CouponModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discountPercent;
  final double maxDiscount;
  final double minOrderAmount;
  final DateTime expiresAt;
  final bool isUsed;
  final String? applicableCategory;

  CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.maxDiscount = 500,
    this.minOrderAmount = 0,
    required this.expiresAt,
    this.isUsed = false,
    this.applicableCategory,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && !isUsed;

  double calculateDiscount(double orderAmount) {
    if (!isValid || orderAmount < minOrderAmount) return 0;
    final discount = orderAmount * (discountPercent / 100);
    return discount > maxDiscount ? maxDiscount : discount;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'description': description,
    'discountPercent': discountPercent,
    'maxDiscount': maxDiscount,
    'minOrderAmount': minOrderAmount,
    'expiresAt': expiresAt.toIso8601String(),
    'isUsed': isUsed,
    'applicableCategory': applicableCategory,
  };

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
    id: json['id'],
    code: json['code'],
    title: json['title'],
    description: json['description'],
    discountPercent: (json['discountPercent'] as num).toDouble(),
    maxDiscount: (json['maxDiscount'] as num? ?? 500).toDouble(),
    minOrderAmount: (json['minOrderAmount'] as num? ?? 0).toDouble(),
    expiresAt: DateTime.parse(json['expiresAt']),
    isUsed: json['isUsed'] ?? false,
    applicableCategory: json['applicableCategory'],
  );
}
