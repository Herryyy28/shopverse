import 'package:flutter/material.dart';
import 'package:shopverse/models/coupon_model.dart';

class CouponProvider with ChangeNotifier {
  CouponModel? _appliedCoupon;
  final List<CouponModel> _availableCoupons = [
    CouponModel(
      id: 'c1',
      code: 'WELCOME50',
      title: 'Welcome Offer',
      description: 'Get 50% off on your first order!',
      discountPercent: 50,
      maxDiscount: 200,
      minOrderAmount: 199,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    ),
    CouponModel(
      id: 'c2',
      code: 'SHOP20',
      title: 'Flat 20% Off',
      description: '20% off on orders above ₹500',
      discountPercent: 20,
      maxDiscount: 300,
      minOrderAmount: 500,
      expiresAt: DateTime.now().add(const Duration(days: 14)),
    ),
    CouponModel(
      id: 'c3',
      code: 'SVFIRST30',
      title: 'First Timer Deal',
      description: '30% off for new ShopVerse users',
      discountPercent: 30,
      maxDiscount: 150,
      minOrderAmount: 299,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    ),
    CouponModel(
      id: 'c4',
      code: 'MEGA15',
      title: 'Mega Sale',
      description: 'Extra 15% off during mega sale',
      discountPercent: 15,
      maxDiscount: 500,
      minOrderAmount: 1000,
      expiresAt: DateTime.now().add(const Duration(days: 3)),
    ),
    CouponModel(
      id: 'c5',
      code: 'GROCERY10',
      title: 'Grocery Saver',
      description: '10% off on all grocery items',
      discountPercent: 10,
      maxDiscount: 100,
      minOrderAmount: 200,
      expiresAt: DateTime.now().add(const Duration(days: 21)),
      applicableCategory: 'Grocery',
    ),
    CouponModel(
      id: 'c6',
      code: 'FREEDELIVERY',
      title: 'Free Delivery',
      description: 'Free delivery on orders above ₹149',
      discountPercent: 100,
      maxDiscount: 40,
      minOrderAmount: 149,
      expiresAt: DateTime.now().add(const Duration(days: 10)),
    ),
  ];

  CouponModel? get appliedCoupon => _appliedCoupon;
  List<CouponModel> get availableCoupons => _availableCoupons.where((c) => c.isValid).toList();

  double getDiscount(double orderAmount) {
    if (_appliedCoupon == null) return 0;
    return _appliedCoupon!.calculateDiscount(orderAmount);
  }

  String? applyCoupon(String code, double orderAmount) {
    final coupon = _availableCoupons.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => CouponModel(
        id: '', code: '', title: '', description: '',
        discountPercent: 0, expiresAt: DateTime(2000),
      ),
    );

    if (coupon.id.isEmpty) return 'Invalid coupon code';
    if (coupon.isExpired) return 'This coupon has expired';
    if (coupon.isUsed) return 'This coupon has already been used';
    if (orderAmount < coupon.minOrderAmount) {
      return 'Minimum order amount is ₹${coupon.minOrderAmount.toInt()}';
    }

    _appliedCoupon = coupon;
    notifyListeners();
    return null; // success
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  CouponModel? getBestCoupon(double orderAmount) {
    CouponModel? best;
    double bestDiscount = 0;
    for (var coupon in availableCoupons) {
      final disc = coupon.calculateDiscount(orderAmount);
      if (disc > bestDiscount) {
        bestDiscount = disc;
        best = coupon;
      }
    }
    return best;
  }
}
