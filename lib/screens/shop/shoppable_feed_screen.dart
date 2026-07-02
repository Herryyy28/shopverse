import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/utils/app_colors.dart';

class ShoppableFeedScreen extends StatefulWidget {
  const ShoppableFeedScreen({super.key});

  @override
  State<ShoppableFeedScreen> createState() => _ShoppableFeedScreenState();
}

class _ShoppableFeedScreenState extends State<ShoppableFeedScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _feedData = [
    {
      'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-shoes-in-a-shoe-box-43308-large.mp4',
      'creator': 'Rider Herry',
      'caption': 'Unboxing the new Swift-Run Nitro Sneaker! The cushioning is crazy comfort.',
      'product': Product(
        id: 'p_shoes_feed',
        name: 'Swift-Run Nitro Running Shoes',
        brand: 'SHOPVERSE RUN',
        description: 'Super responsive running shoes',
        price: 120.0,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
        category: 'Footwear',
      ),
    },
    {
      'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-holding-wireless-headphones-close-up-43283-large.mp4',
      'creator': 'Priya S.',
      'caption': 'Midnight Purple wireless headphones soundcheck. Bass goes deep!',
      'product': Product(
        id: 'p_headphones_feed',
        name: 'Aura Pro Wireless Headphones',
        brand: 'AURA',
        description: 'Noise cancelling purple headphones',
        price: 299.0,
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
        category: 'Electronics',
      ),
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _feedData.length,
        itemBuilder: (context, index) {
          final data = _feedData[index];
          return _FeedVideoItem(
            videoUrl: data['videoUrl'] as String,
            creator: data['creator'] as String,
            caption: data['caption'] as String,
            product: data['product'] as Product,
          );
        },
      ),
    );
  }
}

class _FeedVideoItem extends StatefulWidget {
  final String videoUrl;
  final String creator;
  final String caption;
  final Product product;

  const _FeedVideoItem({
    required this.videoUrl,
    required this.creator,
    required this.caption,
    required this.product,
  });

  @override
  State<_FeedVideoItem> createState() => _FeedVideoItemState();
}

class _FeedVideoItemState extends State<_FeedVideoItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
        _controller.setVolume(0.0); // start muted to avoid browser/os limits
      }).catchError((e) {
        debugPrint('Feed unboxing video error: $e');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerLike() {
    setState(() {
      _showHeart = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
      }
    });
  }

  void _buyItem() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(widget.product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.product.name} to bag!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video viewport card
        Positioned.fill(
          child: GestureDetector(
            onDoubleTap: _triggerLike,
            onTap: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            },
            child: _initialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
        ),

        // Hearts pop overlays
        if (_showHeart)
          const Center(
            child: Icon(Icons.favorite, color: Colors.redAccent, size: 90),
          ),

        // Bottom Details text and Captions
        Positioned(
          left: 16,
          bottom: 120,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${widget.creator}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                widget.caption,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Right Action controls panel
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            children: [
              _buildActionButton(Icons.favorite, '2.4k', () {}),
              const SizedBox(height: 16),
              _buildActionButton(Icons.mode_comment, '184', () {}),
              const SizedBox(height: 16),
              _buildActionButton(Icons.share, 'Share', () {}),
            ],
          ),
        ),

        // Floating Glass product card with Buy button at the bottom
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.product.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${widget.product.price.toInt()}',
                        style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _buyItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('BUY NOW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
