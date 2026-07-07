import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/models/review_model.dart';
import 'package:shopverse/providers/review_provider.dart';
import 'package:shopverse/utils/app_colors.dart';

class ReviewSectionWidget extends StatelessWidget {
  final String productId;
  const ReviewSectionWidget({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProv, _) {
        final reviews = reviewProv.getReviewsForProduct(productId);
        final avgRating = reviewProv.getAverageRating(productId);
        final distribution = reviewProv.getRatingDistribution(productId);
        final total = reviews.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text('Ratings & Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const Spacer(),
                _buildWriteReviewButton(context),
              ],
            ),
            const SizedBox(height: 16),

            // Rating overview
            _buildRatingOverview(avgRating, total, distribution),
            const SizedBox(height: 20),

            // Sort & Filter bar
            _buildSortFilterBar(context, reviewProv),
            const SizedBox(height: 16),

            // Reviews list
            ...reviews.take(5).map((review) => _buildReviewCard(context, review, reviewProv)),

            if (reviews.length > 5)
              Center(
                child: TextButton(
                  onPressed: () => _showAllReviews(context, reviews, reviewProv),
                  child: Text(
                    'View All ${reviews.length} Reviews',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWriteReviewButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showWriteReviewSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rate_review_outlined, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text('Write Review', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingOverview(double avgRating, int total, Map<int, int> distribution) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Left: Big rating number
          Column(
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900),
              ),
              Row(
                children: List.generate(5, (i) {
                  if (i < avgRating.floor()) {
                    return const Icon(Icons.star_rounded, color: Colors.amber, size: 18);
                  } else if (i < avgRating) {
                    return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 18);
                  }
                  return Icon(Icons.star_outline_rounded, color: Colors.grey[300], size: 18);
                }),
              ),
              const SizedBox(height: 6),
              Text(
                '$total ratings',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(width: 28),
          // Right: Distribution bars
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = distribution[star] ?? 0;
                final percent = total > 0 ? count / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 6,
                            backgroundColor: Colors.grey[100],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              star >= 4 ? Colors.green : (star == 3 ? Colors.amber : Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '$count',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortFilterBar(BuildContext context, ReviewProvider reviewProv) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Sort dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: PopupMenuButton<String>(
              onSelected: (v) => reviewProv.setSortBy(v),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'newest', child: Text('Newest First')),
                const PopupMenuItem(value: 'highest', child: Text('Highest Rated')),
                const PopupMenuItem(value: 'lowest', child: Text('Lowest Rated')),
                const PopupMenuItem(value: 'helpful', child: Text('Most Helpful')),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    _sortLabel(reviewProv.sortBy),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Rating filter chips
          ...[5, 4, 3, 2, 1].map((star) {
            final isSelected = reviewProv.filterRating == star;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => reviewProv.setFilterRating(star),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: isSelected ? Colors.white : Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '$star',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, ReviewModel review, ReviewProvider reviewProv) {
    final timeAgo = _timeAgo(review.createdAt);
    final hasVoted = reviewProv.hasVotedHelpful(review.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        if (review.isVerifiedPurchase) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 10, color: Colors.green),
                                SizedBox(width: 2),
                                Text('Verified', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(timeAgo, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              // Star rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: review.rating >= 4 ? Colors.green : (review.rating >= 3 ? Colors.amber : Colors.redAccent),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      review.rating.toStringAsFixed(0),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Review title
          if (review.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(review.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),

          // Review text
          Text(review.comment, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),

          // Review images
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                itemBuilder: (context, i) {
                  return Container(
                    width: 72,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: review.images[i],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey[100]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Seller reply
          if (review.sellerReply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.store, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Seller Response', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(review.sellerReply!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Helpful button
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  reviewProv.toggleHelpful(productId, review.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasVoted ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: hasVoted ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 14,
                        color: hasVoted ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Helpful (${review.helpfulCount})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: hasVoted ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWriteReviewSheet(BuildContext context) {
    double selectedRating = 0;
    final titleController = TextEditingController();
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(height: 20),
                    const Text('Write a Review', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    const Text('Share your experience with this product', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 24),

                    // Star selection
                    const Text('Rating', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedRating = (i + 1).toDouble()),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              i < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 40,
                              color: i < selectedRating ? Colors.amber : Colors.grey[300],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text('Title (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Summarize your experience',
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Comment
                    const Text('Your Review', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'What did you like or dislike?',
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: selectedRating > 0 && commentController.text.trim().isNotEmpty
                          ? () {
                              final review = ReviewModel(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                userId: 'current_user',
                                userName: 'You',
                                productId: productId,
                                rating: selectedRating,
                                title: titleController.text.trim(),
                                comment: commentController.text.trim(),
                                createdAt: DateTime.now(),
                                isVerifiedPurchase: true,
                              );
                              Provider.of<ReviewProvider>(context, listen: false).addReview(review);
                              HapticFeedback.mediumImpact();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Review submitted! Thank you 🎉'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAllReviews(BuildContext context, List<ReviewModel> reviews, ReviewProvider reviewProv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text('All Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reviews.length,
                  itemBuilder: (_, i) => _buildReviewCard(context, reviews[i], reviewProv),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _sortLabel(String sortBy) {
    switch (sortBy) {
      case 'newest': return 'Newest';
      case 'highest': return 'Highest';
      case 'lowest': return 'Lowest';
      case 'helpful': return 'Helpful';
      default: return 'Sort';
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return 'Just now';
  }
}
