import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:shopverse/providers/feed_provider.dart';
import 'package:shopverse/providers/product_provider.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/screens/shop/product_details_screen.dart';
import 'package:shopverse/utils/app_colors.dart';

class ShoppableFeedScreen extends StatelessWidget {
  const ShoppableFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ShopTok', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProv, _) {
          if (feedProv.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (feedProv.videos.isEmpty) {
            return const Center(child: Text('No videos available', style: TextStyle(color: Colors.white)));
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: feedProv.videos.length,
            onPageChanged: (index) {
              feedProv.setCurrentIndex(index);
            },
            itemBuilder: (context, index) {
              final video = feedProv.videos[index];
              return Stack(
                children: [
                  // Video Player
                  VideoPlayerItem(
                    videoUrl: video.videoUrl,
                    isActive: feedProv.currentIndex == index,
                  ),

                  // Overlay Content
                  SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left side: Description and Product Card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 8, 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: CachedNetworkImageProvider(video.creatorAvatarUrl),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      video.creatorName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  video.description,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 20),
                                _buildProductCard(context, video.productId),
                              ],
                            ),
                          ),
                        ),

                        // Right side: Interaction Buttons
                        Padding(
                          padding: const EdgeInsets.only(right: 12, bottom: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildInteractionButton(
                                icon: video.isLiked ? Icons.favorite : Icons.favorite_border,
                                color: video.isLiked ? Colors.red : Colors.white,
                                label: '${video.likes}',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  feedProv.toggleLike(video.id);
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildInteractionButton(
                                icon: Icons.comment_rounded,
                                color: Colors.white,
                                label: '${video.comments}',
                                onTap: () {},
                              ),
                              const SizedBox(height: 20),
                              _buildInteractionButton(
                                icon: Icons.share_rounded,
                                color: Colors.white,
                                label: 'Share',
                                onTap: () {},
                              ),
                              const SizedBox(height: 40), // Space above product card
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInteractionButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String productId) {
    return Consumer2<ProductProvider, CartProvider>(
      builder: (context, productProv, cart, _) {
        final product = productProv.products.firstWhere(
          (p) => p.id == productId,
          orElse: () => productProv.products.first,
        );
        final isInCart = cart.items.containsKey(product.id);

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)));
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.white,
                    width: 50,
                    height: 50,
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product.price.toInt()}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (!isInCart) {
                      HapticFeedback.mediumImpact();
                      cart.addItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart from ShopTok! 🛍️'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isInCart ? Colors.green : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isInCart ? Icons.check : Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final bool isActive;

  const VideoPlayerItem({super.key, required this.videoUrl, required this.isActive});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
          if (widget.isActive) {
            _controller.play();
          }
        });
      }).catchError((error) {
        debugPrint("Error initializing video: $error");
      });
  }

  @override
  void didUpdateWidget(VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized) {
      if (widget.isActive && !oldWidget.isActive) {
        _controller.play();
      } else if (!widget.isActive && oldWidget.isActive) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return GestureDetector(
      onTap: () {
        if (_controller.value.isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
        setState(() {}); // Update play/pause icon overlay
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
          if (!_controller.value.isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, color: Colors.white54, size: 80),
            ),
        ],
      ),
    );
  }
}
