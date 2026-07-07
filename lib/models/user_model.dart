class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final String role; // 'customer' or 'admin'
  final double walletBalance;
  final List<String> wishlist;
  final DateTime createdAt;
  final String? storeName;
  final String? storeBannerUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    this.role = 'customer',
    this.walletBalance = 0.0,
    this.wishlist = const [],
    required this.createdAt,
    this.storeName,
    this.storeBannerUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'walletBalance': walletBalance,
      'wishlist': wishlist,
      'createdAt': createdAt.toIso8601String(),
      'storeName': storeName,
      'storeBannerUrl': storeBannerUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImageUrl: json['profileImageUrl'],
      role: json['role'] ?? 'customer',
      walletBalance: (json['walletBalance'] ?? 0.0).toDouble(),
      wishlist: List<String>.from(json['wishlist'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      storeName: json['storeName'],
      storeBannerUrl: json['storeBannerUrl'],
    );
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? profileImageUrl,
    double? walletBalance,
    List<String>? wishlist,
    String? storeName,
    String? storeBannerUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role,
      walletBalance: walletBalance ?? this.walletBalance,
      wishlist: wishlist ?? this.wishlist,
      createdAt: createdAt,
      storeName: storeName ?? this.storeName,
      storeBannerUrl: storeBannerUrl ?? this.storeBannerUrl,
    );
  }
}
