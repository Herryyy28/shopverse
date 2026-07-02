import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shopverse/utils/app_colors.dart';

class VideoReviewsWidget extends StatelessWidget {
  const VideoReviewsWidget({super.key});

  static final List<Map<String, String>> _reviews = [
    {
      'name': 'Rohan K.',
      'rating': '5★',
      'avatar': 'https://i.pravatar.cc/150?u=rohan',
      'video': 'https://assets.mixkit.co/videos/preview/mixkit-shoes-in-a-shoe-box-43308-large.mp4',
    },
    {
      'name': 'Priya S.',
      'rating': '4.8★',
      'avatar': 'https://i.pravatar.cc/150?u=priya',
      'video': 'https://assets.mixkit.co/videos/preview/mixkit-holding-wireless-headphones-close-up-43283-large.mp4',
    },
    {
      'name': 'Herry P.',
      'rating': '5★',
      'avatar': 'https://i.pravatar.cc/150?u=herry',
      'video': 'https://assets.mixkit.co/videos/preview/mixkit-luxury-gold-watch-close-up-43292-large.mp4',
    }
  ];

  void _showVideoReview(BuildContext context, String name, String videoUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return _ReviewVideoDialog(name: name, videoUrl: videoUrl);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.video_library_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Customer Video Reviews',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row of story bubbles
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final item = _reviews[index];
                return GestureDetector(
                  onTap: () => _showVideoReview(context, item['name']!, item['video']!),
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(item['avatar']!),
                            radius: 26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item['name']} (${item['rating']})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewVideoDialog extends StatefulWidget {
  final String name;
  final String videoUrl;

  const _ReviewVideoDialog({required this.name, required this.videoUrl});

  @override
  State<_ReviewVideoDialog> createState() => _ReviewVideoDialogState();
}

class _ReviewVideoDialogState extends State<_ReviewVideoDialog> {
  late VideoPlayerController _controller;
  bool _initialized = false;

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
        _controller.setVolume(0.0);
      }).catchError((e) {
        debugPrint('Review video player error: $e');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          // Header title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Video Review by ${widget.name}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Video player body
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: _initialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
