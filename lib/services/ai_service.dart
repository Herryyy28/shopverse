class AIService {
  static Future<List<String>> getSearchSuggestions(String query) async {
    // In a real app, this would call a Gemini or GPT-4 API
    await Future.delayed(const Duration(milliseconds: 300));
    
    final mockSuggestions = [
      'Smart home devices',
      'Ergonomic office chairs',
      'Sustainable fashion',
      'Mechanical keyboards for coding',
      'Vegan protein powders',
    ];

    return mockSuggestions
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static Future<String> processVoiceQuery(String voiceText) async {
    // Use AI to extract intent from voice
    // "Show me some red running shoes under 2000" -> "red running shoes price < 2000"
    return voiceText.toLowerCase();
  }

  static Future<List<String>> analyzeImage(String imagePath) async {
    // In a real app, use Google Vision API or a custom ML model
    await Future.delayed(const Duration(seconds: 1));
    return ['Headphones', 'Electronics', 'Wireless'];
  }

  static List<Product> getRecommendations(List<Product> allProducts) {
    // Basic AI logic: return 4 random products as "recommendations"
    final products = List<Product>.from(allProducts);
    products.shuffle();
    return products.take(4).toList();
  }

  static List<Product> getFrequentlyBoughtTogether(Product currentProduct, List<Product> allProducts) {
    // AI logic: return products in same category excluding current
    return allProducts
        .where((p) => p.id != currentProduct.id && p.category == currentProduct.category)
        .take(3)
        .toList();
  }

  static Future<String> getProductRecommendation(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return "Based on your interest in fitness, we recommend the 'Swift-Run Nitro Pro' for your next marathon!";
  }

  static Future<String> getSizeRecommendation(String productId, Map<String, dynamic> userProfile) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return "Based on your previous purchases, Size 'L' would fit you best for this item.";
  }

  static Future<List<String>> getProductComparison(String productId1, String productId2) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      "Product A has better battery life (40h vs 30h).",
      "Product B is 20% lighter.",
      "Product A has active noise cancellation, Product B doesn't."
    ];
  }

  static Future<String> getBudgetSuggestion(double budget, String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "With a budget of ₹$budget in $category, you can get a high-quality mid-range smartphone with a great camera.";
  }

  static Future<Map<String, dynamic>> getPersonalizedOffer(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "title": "Exclusive 20% Off",
      "description": "Just for you! Use code AI20 on your next electronics purchase.",
      "code": "AI20"
    };
  }

  static Future<String> getChatbotResponse(String message) async {
    await Future.delayed(const Duration(seconds: 1));
    final msg = message.toLowerCase();
    
    if (msg.contains('order') || msg.contains('track')) {
      return "You can track your latest order #SV9821 in the 'Orders' section. It's currently out for delivery!";
    } else if (msg.contains('refund') || msg.contains('return')) {
      return "To initiate a refund, go to 'Orders', select the item, and click 'Return'. Refunds usually take 3-5 business days.";
    } else if (msg.contains('product') || msg.contains('info') || msg.contains('details')) {
      return "I can help with that! Which product are you interested in? I can provide specs, reviews, and current availability.";
    } else if (msg.contains('hello') || msg.contains('hi')) {
      return "Hello! I'm your ShopVerse AI Assistant. How can I help you today with product info, orders, or refunds?";
    } else {
      return "I'm still learning! But I can help you track orders, find product info, or process refunds. What do you need?";
    }
  }
}
