import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/utils/app_colors.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final List<Map<String, dynamic>> _feedItems = [
    {
      'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-shoes-in-a-shoe-box-43308-large.mp4',
      'product': Product(
        id: 'p000',
        name: 'Swift-Run Nitro Pro - Crimson',
        brand: 'SWIFT',
        description: 'Ultra-lightweight running shoes with Nitro-foam technology.',
        price: 120.0,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
        category: 'Footwear',
      ),
      'likes': 1240,
    },
    {
      'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-holding-wireless-headphones-close-up-43283-large.mp4',
      'product': Product(
        id: 'p0',
        name: 'Aura Pro Wireless Headphones - Midnight Purple',
        brand: 'AURA',
        description: 'Immersive sound with active noise cancellation.',
        price: 299.0,
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
        category: 'Electronics',
      ),
      'likes': 850,
    },
    {
      'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-luxury-gold-watch-close-up-43292-large.mp4',
      'product': Product(
        id: 'p00',
        name: 'Chronos Classic Steel Edition',
        brand: 'CHRONOS',
        description: 'Timeless watch design meets precision modern metrics.',
        price: 185.0,
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        category: 'Accessories',
      ),
      'likes': 962,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _feedItems.length,
        itemBuilder: (context, index) {
          return _VideoPageItem(
            videoUrl: _feedItems[index]['videoUrl'] as String,
            product: _feedItems[index]['product'] as Product,
            likes: _feedItems[index]['likes'] as int,
          );
        },
      ),
    );
  }
}

class _VideoPageItem extends StatefulWidget {
  final String videoUrl;
  final Product product;
  final int likes;

  const _VideoPageItem({
    required this.videoUrl,
    required this.product,
    required this.likes,
  });

  @override
  State<_VideoPageItem> createState() => _VideoPageItemState();
}

class _VideoPageItemState extends State<_VideoPageItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _liked = false;
  bool _showHeart = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likes;
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
        _controller.setVolume(0.0); // Mute by default to avoid browser blocking
      }).catchError((e) {
        debugPrint("Video Player initialization error: $e");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    setState(() {
      _showHeart = true;
      if (!_liked) {
        _liked = true;
        _likeCount++;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      onTap: () {
        if (_controller.value.isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          _initialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

          // Double Tap Heart Overlay
          if (_showHeart)
            Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(begin: 0.0, end: 1.2),
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 100,
                    ),
                  );
                },
              ),
            ),

          // Overlay Bottom Info Panel
          Positioned(
            bottom: 30,
            left: 20,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_bag, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        widget.product.brand.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.product.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                
                // Add to bag direct overlay widget
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Flash Sale Price', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            Text(
                              '₹${widget.product.price.toInt()}',
                              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false).addItem(widget.product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to Bag!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('BUY NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sidebar Action Controls
          Positioned(
            bottom: 50,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionIcon(
                  icon: _liked ? Icons.favorite : Icons.favorite_border,
                  color: _liked ? Colors.red : Colors.white,
                  label: '$_likeCount',
                  onTap: () {
                    setState(() {
                      _liked = !_liked;
                      _liked ? _likeCount++ : _likeCount--;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildActionIcon(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.white,
                  label: '48',
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                _buildActionIcon(
                  icon: Icons.share,
                  color: Colors.white,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
