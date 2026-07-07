import 'package:flutter/material.dart';
import 'package:shopverse/models/shoppable_video.dart';

class FeedProvider with ChangeNotifier {
  List<ShoppableVideo> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  List<ShoppableVideo> get videos => _videos;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;

  FeedProvider() {
    _loadInitialVideos();
  }

  void _loadInitialVideos() {
    // Simulated video data (since we need vertical videos for a TikTok-like experience)
    // We use some public sample MP4 URLs.
    _videos = [
      ShoppableVideo(
        id: 'v1',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        productId: 'p4', // Matches Aura Pro Wireless Headphones
        creatorName: '@tech_guru',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
        description: 'These headphones are INSANE! The active noise cancellation block out everything. 🎧🔥 #tech #headphones',
        likes: 14500,
        comments: 342,
      ),
      ShoppableVideo(
        id: 'v2',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        productId: 'p0', // Matches Neon Velocity G7 Pro
        creatorName: '@sneakerhead_dan',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100',
        description: 'Unboxing the new Neon Velocity G7 Pro! Look at that glow! 👟✨ #sneakers #fashion',
        likes: 8200,
        comments: 120,
      ),
      ShoppableVideo(
        id: 'v3',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // Reusing dummy for now
        productId: 'p5', // Chronos Classic Steel Edition
        creatorName: '@style_by_sarah',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
        description: 'The perfect watch for any outfit. ⌚ Chronos Classic is a must-have. #watch #style',
        likes: 21300,
        comments: 890,
      ),
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (index != _currentIndex) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void toggleLike(String videoId) {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index >= 0) {
      final video = _videos[index];
      if (video.isLiked) {
        video.isLiked = false;
        video.likes--;
      } else {
        video.isLiked = true;
        video.likes++;
      }
      notifyListeners();
    }
  }
}
