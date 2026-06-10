class Product {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final double oldPrice;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviews;
  final bool isVeg;
  final String unit;

  Product({
    required this.id,
    required this.name,
    this.brand = 'ShopVerse',
    required this.description,
    required this.price,
    this.oldPrice = 0,
    required this.imageUrl,
    required this.category,
    this.rating = 4.5,
    this.reviews = 100,
    this.isVeg = true,
    this.unit = 'unit',
  });

  int get discount => oldPrice > price 
      ? (((oldPrice - price) / oldPrice) * 100).round() 
      : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviews': reviews,
      'isVeg': isVeg,
      'unit': unit,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      oldPrice: (json['oldPrice'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviews: json['reviews'] ?? 100,
      isVeg: json['isVeg'] ?? true,
      unit: json['unit'] ?? 'unit',
    );
  }
}
