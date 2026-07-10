import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/wishlist_provider.dart';
import 'package:shopverse/screens/shop/product_details_screen.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/utils/app_spacing.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final bgColor = isDark ? AppColors.darkSurface2 : const Color(0xFFF5F6FA);

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: widget.product)),
        );
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: AppRadius.xlBR,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Section ────────────────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                      child: Container(
                        width: double.infinity,
                        color: bgColor,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: CachedNetworkImage(
                              imageUrl: widget.product.imageUrl,
                              placeholder: (c, u) => Shimmer.fromColors(
                                baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                                highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (c, u, e) => Icon(
                                Icons.image_outlined,
                                color: AppColors.textMuted,
                                size: 36,
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Discount badge
                    if (widget.product.discount > 0)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '${widget.product.discount}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),

                    // Wishlist heart
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _WishlistHeart(product: widget.product),
                    ),
                  ],
                ),
              ),

              // ── Info Section ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.product.unit,
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${widget.product.price.toInt()}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            if (widget.product.oldPrice > widget.product.price)
                              Text(
                                '₹${widget.product.oldPrice.toInt()}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                        AddButtonSmall(product: widget.product),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated Wishlist Heart ───────────────────────────────────────────────────
class _WishlistHeart extends StatefulWidget {
  final Product product;
  const _WishlistHeart({required this.product});

  @override
  State<_WishlistHeart> createState() => _WishlistHeartState();
}

class _WishlistHeartState extends State<_WishlistHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlist, _) {
        final isFav = wishlist.isFavorite(widget.product.id);
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            wishlist.toggleWishlist(widget.product);
            _controller.forward(from: 0);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ScaleTransition(
              scale: _scale,
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? AppColors.brandRed : Colors.grey[400],
                size: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Animated ADD Button ───────────────────────────────────────────────────────
class AddButtonSmall extends StatefulWidget {
  final Product product;
  const AddButtonSmall({super.key, required this.product});

  @override
  State<AddButtonSmall> createState() => _AddButtonSmallState();
}

class _AddButtonSmallState extends State<AddButtonSmall> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final cartItem = cart.items[widget.product.id];
        final isInCart = cartItem != null;

        if (!isInCart) {
          return GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              HapticFeedback.lightImpact();
              cart.addItem(widget.product);
            },
            onTapCancel: () => _controller.reverse(),
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'ADD',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  cart.removeSingleItem(widget.product.id);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Icon(Icons.remove_rounded, color: Colors.white, size: 15),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Text(
                  '${cartItem.quantity}',
                  key: ValueKey(cartItem.quantity),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  cart.addItem(widget.product);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Icon(Icons.add_rounded, color: Colors.white, size: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
