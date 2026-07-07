import 'package:flutter/material.dart';
import 'package:shopverse/models/review_model.dart';

class ReviewProvider with ChangeNotifier {
  final Map<String, List<ReviewModel>> _productReviews = {};
  final Set<String> _helpfulVotes = {};
  String _sortBy = 'newest';
  int? _filterRating;

  // Generate mock reviews for any product
  List<ReviewModel> getReviewsForProduct(String productId) {
    if (!_productReviews.containsKey(productId)) {
      _productReviews[productId] = _generateMockReviews(productId);
    }
    var reviews = List<ReviewModel>.from(_productReviews[productId]!);

    // Apply filter
    if (_filterRating != null) {
      reviews = reviews.where((r) => r.rating.round() == _filterRating).toList();
    }

    // Apply sort
    switch (_sortBy) {
      case 'newest':
        reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'highest':
        reviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        reviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'helpful':
        reviews.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        break;
    }
    return reviews;
  }

  String get sortBy => _sortBy;
  int? get filterRating => _filterRating;

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setFilterRating(int? rating) {
    _filterRating = (_filterRating == rating) ? null : rating;
    notifyListeners();
  }

  double getAverageRating(String productId) {
    final reviews = getReviewsForProduct(productId);
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  Map<int, int> getRatingDistribution(String productId) {
    final reviews = getReviewsForProduct(productId);
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in reviews) {
      dist[r.rating.round()] = (dist[r.rating.round()] ?? 0) + 1;
    }
    return dist;
  }

  void addReview(ReviewModel review) {
    if (!_productReviews.containsKey(review.productId)) {
      _productReviews[review.productId] = [];
    }
    _productReviews[review.productId]!.insert(0, review);
    notifyListeners();
  }

  bool hasVotedHelpful(String reviewId) => _helpfulVotes.contains(reviewId);

  void toggleHelpful(String productId, String reviewId) {
    final reviews = _productReviews[productId];
    if (reviews == null) return;

    final index = reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return;

    final review = reviews[index];
    if (_helpfulVotes.contains(reviewId)) {
      _helpfulVotes.remove(reviewId);
      reviews[index] = ReviewModel(
        id: review.id,
        userId: review.userId,
        userName: review.userName,
        userAvatar: review.userAvatar,
        productId: review.productId,
        rating: review.rating,
        title: review.title,
        comment: review.comment,
        images: review.images,
        createdAt: review.createdAt,
        helpfulCount: review.helpfulCount - 1,
        unhelpfulCount: review.unhelpfulCount,
        isVerifiedPurchase: review.isVerifiedPurchase,
        sellerReply: review.sellerReply,
      );
    } else {
      _helpfulVotes.add(reviewId);
      reviews[index] = ReviewModel(
        id: review.id,
        userId: review.userId,
        userName: review.userName,
        userAvatar: review.userAvatar,
        productId: review.productId,
        rating: review.rating,
        title: review.title,
        comment: review.comment,
        images: review.images,
        createdAt: review.createdAt,
        helpfulCount: review.helpfulCount + 1,
        unhelpfulCount: review.unhelpfulCount,
        isVerifiedPurchase: review.isVerifiedPurchase,
        sellerReply: review.sellerReply,
      );
    }
    notifyListeners();
  }

  List<ReviewModel> _generateMockReviews(String productId) {
    return [
      ReviewModel(
        id: '${productId}_r1',
        userId: 'u1',
        userName: 'Priya Sharma',
        productId: productId,
        rating: 5,
        title: 'Absolutely love it!',
        comment: 'Best purchase I have made this year. The quality is premium and it arrived earlier than expected. Highly recommend to everyone!',
        images: [
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200',
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        helpfulCount: 42,
        isVerifiedPurchase: true,
        sellerReply: 'Thank you for your kind words, Priya! We are glad you loved it. 💜',
      ),
      ReviewModel(
        id: '${productId}_r2',
        userId: 'u2',
        userName: 'Rahul Verma',
        productId: productId,
        rating: 4,
        title: 'Great value for money',
        comment: 'Product is exactly as described. Packaging was excellent. Only minor issue is the delivery took a bit longer than expected. But overall very satisfied with the quality.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        helpfulCount: 28,
        isVerifiedPurchase: true,
      ),
      ReviewModel(
        id: '${productId}_r3',
        userId: 'u3',
        userName: 'Ananya Gupta',
        productId: productId,
        rating: 5,
        title: 'Perfect gift!',
        comment: 'Bought this as a gift and it was a huge hit! The unboxing experience was delightful. Will definitely order again for myself this time.',
        images: [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        helpfulCount: 15,
        isVerifiedPurchase: false,
      ),
      ReviewModel(
        id: '${productId}_r4',
        userId: 'u4',
        userName: 'Vikram Singh',
        productId: productId,
        rating: 3,
        title: 'Decent but expected more',
        comment: 'The product is okay but I expected better build quality at this price point. It works fine for daily use though. Average experience overall.',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        helpfulCount: 8,
        isVerifiedPurchase: true,
      ),
      ReviewModel(
        id: '${productId}_r5',
        userId: 'u5',
        userName: 'Meera Nair',
        productId: productId,
        rating: 5,
        title: 'Exceeded expectations!',
        comment: 'I was skeptical at first but this product blew me away! Premium feel, amazing performance, and the ShopVerse delivery was super fast. 10/10 recommend!',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        helpfulCount: 35,
        isVerifiedPurchase: true,
        sellerReply: 'Thank you Meera! Your feedback means the world to us! 🌟',
      ),
      ReviewModel(
        id: '${productId}_r6',
        userId: 'u6',
        userName: 'Arjun Patel',
        productId: productId,
        rating: 4,
        title: 'Solid product',
        comment: 'Good build quality and performs as advertised. The customer service was also very helpful when I had a query. Would buy from this brand again.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        helpfulCount: 12,
        isVerifiedPurchase: true,
      ),
    ];
  }
}
