import '../models/product.dart';

class AIService {
  // Simulate AI recommendation engine
  static List<Product> getRecommendations(List<Product> allProducts, {String? category}) {
    // In a real app, this would use ML models or complex algorithms based on user history
    if (category != null) {
      return allProducts.where((p) => p.category == category).take(5).toList();
    }
    
    // Default: Return trending/random items as recommendations
    return (List<Product>.from(allProducts)..shuffle()).take(4).toList();
  }

  static List<Product> getFrequentlyBoughtTogether(Product product, List<Product> allProducts) {
    // Simple logic: products in the same category or common pairings
    return allProducts
        .where((p) => p.id != product.id && p.category == product.category)
        .take(3)
        .toList();
  }
}
