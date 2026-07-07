class ShoppableVideo {
  final String id;
  final String videoUrl;
  final String productId;
  final String creatorName;
  final String creatorAvatarUrl;
  final String description;
  int likes;
  int comments;
  bool isLiked;

  ShoppableVideo({
    required this.id,
    required this.videoUrl,
    required this.productId,
    required this.creatorName,
    required this.creatorAvatarUrl,
    required this.description,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory ShoppableVideo.fromJson(Map<String, dynamic> json) {
    return ShoppableVideo(
      id: json['id'] as String,
      videoUrl: json['videoUrl'] as String,
      productId: json['productId'] as String,
      creatorName: json['creatorName'] as String,
      creatorAvatarUrl: json['creatorAvatarUrl'] as String,
      description: json['description'] as String,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'productId': productId,
      'creatorName': creatorName,
      'creatorAvatarUrl': creatorAvatarUrl,
      'description': description,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
    };
  }
}
