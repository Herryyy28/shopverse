class ProductVariant {
  final String id;
  final String name; // e.g., "Color", "Size"
  final List<String> options; // e.g., ["Red", "Blue"] or ["S", "M", "L"]

  ProductVariant({
    required this.id,
    required this.name,
    required this.options,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'options': options,
  };

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    id: json['id'],
    name: json['name'],
    options: List<String>.from(json['options']),
  );
}

class Product {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final double oldPrice;
  final String imageUrl; // Primary thumbnail
  final List<String> images; // Multiple images
  final String category;
  final double rating;
  final int reviews;
  final bool isVeg;
  final String unit;
  final List<ProductVariant> variants;
  final Map<String, String> specifications;
  final String? videoUrl;
  final String? arModelUrl;
  final String? view360Url;

  Product({
    required this.id,
    required this.name,
    this.brand = 'ShopVerse',
    required this.description,
    required this.price,
    this.oldPrice = 0,
    required this.imageUrl,
    this.images = const [],
    required this.category,
    this.rating = 4.5,
    this.reviews = 100,
    this.isVeg = true,
    this.unit = 'unit',
    this.variants = const [],
    this.specifications = const {},
    this.videoUrl,
    this.arModelUrl,
    this.view360Url,
  });

  int get discount => oldPrice > price 
      ? (((oldPrice - price) / oldPrice) * 100).round() 
      : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'images': images,
      'category': category,
      'rating': rating,
      'reviews': reviews,
      'isVeg': isVeg,
      'unit': unit,
      'variants': variants.map((v) => v.toJson()).toList(),
      'specifications': specifications,
      'videoUrl': videoUrl,
      'arModelUrl': arModelUrl,
      'view360Url': view360Url,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      brand: json['brand'] ?? 'ShopVerse',
      description: json['description'],
      price: json['price'].toDouble(),
      oldPrice: (json['oldPrice'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      images: List<String>.from(json['images'] ?? []),
      category: json['category'],
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviews: json['reviews'] ?? 100,
      isVeg: json['isVeg'] ?? true,
      unit: json['unit'] ?? 'unit',
      variants: (json['variants'] as List?)?.map((v) => ProductVariant.fromJson(v)).toList() ?? [],
      specifications: Map<String, String>.from(json['specifications'] ?? {}),
      videoUrl: json['videoUrl'],
      arModelUrl: json['arModelUrl'],
      view360Url: json['view360Url'],
    );
  }
}
