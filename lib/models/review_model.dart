class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String productId;
  final double rating;
  final String title;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final int helpfulCount;
  final int unhelpfulCount;
  final bool isVerifiedPurchase;
  final String? sellerReply;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.productId,
    required this.rating,
    this.title = '',
    required this.comment,
    this.images = const [],
    required this.createdAt,
    this.helpfulCount = 0,
    this.unhelpfulCount = 0,
    this.isVerifiedPurchase = false,
    this.sellerReply,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userAvatar': userAvatar,
    'productId': productId,
    'rating': rating,
    'title': title,
    'comment': comment,
    'images': images,
    'createdAt': createdAt.toIso8601String(),
    'helpfulCount': helpfulCount,
    'unhelpfulCount': unhelpfulCount,
    'isVerifiedPurchase': isVerifiedPurchase,
    'sellerReply': sellerReply,
  };

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    userAvatar: json['userAvatar'],
    productId: json['productId'],
    rating: (json['rating'] as num).toDouble(),
    title: json['title'] ?? '',
    comment: json['comment'],
    images: List<String>.from(json['images'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    helpfulCount: json['helpfulCount'] ?? 0,
    unhelpfulCount: json['unhelpfulCount'] ?? 0,
    isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
    sellerReply: json['sellerReply'],
  );
}
