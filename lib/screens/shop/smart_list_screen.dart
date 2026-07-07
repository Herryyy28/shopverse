import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/product_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';
import 'package:shopverse/widgets/voice_visualizer_dialog.dart';

class SmartListScreen extends StatefulWidget {
  const SmartListScreen({super.key});

  @override
  State<SmartListScreen> createState() => _SmartListScreenState();
}

class ParsedItem {
  final String originalText;
  final String searchText;
  Product? matchedProduct;
  int quantity;
  bool isSelected;

  ParsedItem({
    required this.originalText,
    required this.searchText,
    this.matchedProduct,
    this.quantity = 1,
    this.isSelected = true,
  });
}

class _SmartListScreenState extends State<SmartListScreen> {
  final TextEditingController _listController = TextEditingController();
  List<ParsedItem> _parsedItems = [];
  bool _isParsing = false;

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  void _loadExample() {
    _listController.text = "2 milk\n1 headphones\n1 sunflower oil\n1 steel watch";
    _parseList();
  }

  void _parseList() {
    final text = _listController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _parsedItems = [];
      });
      return;
    }

    setState(() {
      _isParsing = true;
    });

    final lines = text.split('\n');
    final allProducts = Provider.of<ProductProvider>(context, listen: false).products;
    final List<ParsedItem> tempItems = [];

    for (var line in lines) {
      final cleanLine = line.trim();
      if (cleanLine.isEmpty) continue;

      int qty = 1;
      String searchStr = cleanLine;

      // Extract leading quantity (e.g. "2 milk" -> qty=2, searchStr="milk")
      final leadingMatch = RegExp(r'^(\d+)\s*(?:x|packs?|pcs?|kg|l|ltr|litres?|ml)?\s+(.+)$', caseSensitive: false).firstMatch(cleanLine);
      if (leadingMatch != null) {
        qty = int.tryParse(leadingMatch.group(1) ?? '1') ?? 1;
        searchStr = leadingMatch.group(2) ?? cleanLine;
      } else {
        // Check for trailing quantity (e.g. "milk 2" -> qty=2, searchStr="milk")
        final trailingMatch = RegExp(r'^(.+?)\s+(\d+)\s*(?:x|packs?|pcs?|kg|l|ltr|litres?|ml)?$', caseSensitive: false).firstMatch(cleanLine);
        if (trailingMatch != null) {
          qty = int.tryParse(trailingMatch.group(2) ?? '1') ?? 1;
          searchStr = trailingMatch.group(1) ?? cleanLine;
        }
      }

      // Perform a scoring match over catalog products
      Product? bestMatch;
      double bestScore = 0;
      final queryWords = searchStr.toLowerCase().split(RegExp(r'\s+')).where((w) => w.length > 1).toList();

      for (var product in allProducts) {
        final nameLower = product.name.toLowerCase();
        final brandLower = product.brand.toLowerCase();
        final catLower = product.category.toLowerCase();

        double score = 0;

        // Exact match
        if (nameLower == searchStr.toLowerCase()) {
          score += 10.0;
        } else if (nameLower.startsWith(searchStr.toLowerCase())) {
          score += 8.0;
        } else if (nameLower.contains(searchStr.toLowerCase())) {
          score += 5.0;
        }

        // Token match overlap
        int overlapCount = 0;
        for (var word in queryWords) {
          if (nameLower.contains(word) || brandLower.contains(word) || catLower.contains(word)) {
            overlapCount++;
          }
        }
        if (queryWords.isNotEmpty) {
          score += (overlapCount / queryWords.length) * 3.0;
        }

        if (score > bestScore && score > 0.5) {
          bestScore = score;
          bestMatch = product;
        }
      }

      tempItems.add(ParsedItem(
        originalText: cleanLine,
        searchText: searchStr,
        matchedProduct: bestMatch,
        quantity: qty,
        isSelected: bestMatch != null,
      ));
    }

    setState(() {
      _parsedItems = tempItems;
      _isParsing = false;
    });
  }

  Future<void> _startVoiceInput() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const VoiceVisualizerDialog(),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        if (_listController.text.trim().isEmpty) {
          _listController.text = result;
        } else {
          _listController.text += '\n$result';
        }
      });
      _parseList();
    }
  }

  void _showLinkProductDialog(ParsedItem item) {
    final allProducts = Provider.of<ProductProvider>(context, listen: false).products;
    String filterQuery = item.searchText;
    List<Product> searchResults = allProducts
        .where((p) => p.name.toLowerCase().contains(filterQuery.toLowerCase()))
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Link Product for "${item.originalText}"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          filterQuery = val;
                          searchResults = allProducts
                              .where((p) => p.name.toLowerCase().contains(filterQuery.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: searchResults.isEmpty
                          ? const Center(child: Text('No matching products found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: searchResults.length,
                              itemBuilder: (context, i) {
                                final product = searchResults[i];
                                return ListTile(
                                  leading: CachedNetworkImage(
                                    imageUrl: product.imageUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                    errorWidget: (context, url, error) => const Icon(Icons.shopping_bag_outlined),
                                  ),
                                  title: Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  subtitle: Text('₹${product.price.toInt()} • ${product.category}'),
                                  onTap: () {
                                    setState(() {
                                      item.matchedProduct = product;
                                      item.isSelected = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addSelectedToCart() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final selectedItems = _parsedItems.where((i) => i.isSelected && i.matchedProduct != null).toList();

    if (selectedItems.isEmpty) return;

    for (var item in selectedItems) {
      cart.addItemWithQuantity(item.matchedProduct!, item.quantity);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${selectedItems.length} items to your shopping bag! 🛒'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  double get _totalPrice {
    double total = 0;
    for (var item in _parsedItems) {
      if (item.isSelected && item.matchedProduct != null) {
        total += item.matchedProduct!.price * item.quantity;
      }
    }
    return total;
  }

  int get _selectedCount {
    return _parsedItems.where((i) => i.isSelected && i.matchedProduct != null).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('AI Smart List Importer', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text Area Input Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Type or paste your shopping list',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Enter one item per line (e.g. 2 milk, 1 headphones)',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _listController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "e.g.,\n2 milk\n1 headphones\n1 sunflower oil\n1 watch",
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            fillColor: isDark ? const Color(0xFF141424) : AppColors.backgroundColor,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => _parseList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _startVoiceInput,
                                icon: const Icon(Icons.mic, color: Colors.blueAccent),
                                label: const Text('RECORD LIST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.08),
                                  foregroundColor: Colors.blueAccent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _parseList,
                                icon: const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                                label: const Text('PARSE LIST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent.withValues(alpha: 0.08),
                                  foregroundColor: Colors.purpleAccent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Match Checklist Results Header
                  if (_parsedItems.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Parsed Verification Checklist',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          '$_selectedCount matched items',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Parsed Checklist or Empty Placeholder
                  if (_isParsing)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (_parsedItems.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _parsedItems.length,
                      itemBuilder: (context, index) {
                        final item = _parsedItems[index];
                        final isMatched = item.matchedProduct != null;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isMatched
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.orange.withValues(alpha: 0.15),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: item.isSelected && isMatched,
                                activeColor: Colors.green,
                                onChanged: isMatched
                                    ? (val) {
                                        setState(() {
                                          item.isSelected = val ?? false;
                                        });
                                      }
                                    : null,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.originalText,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    if (isMatched)
                                      Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Matched: ${item.matchedProduct!.name} (${item.matchedProduct!.unit})',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        children: [
                                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 14),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'No product match found',
                                            style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isMatched) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (item.quantity > 1) {
                                          setState(() => item.quantity--);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                                        child: const Icon(Icons.remove, size: 14, color: Colors.black54),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() => item.quantity++);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                                        child: const Icon(Icons.add, size: 14, color: Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '₹${(item.matchedProduct!.price * item.quantity).toInt()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ] else
                                TextButton(
                                  onPressed: () => _showLinkProductDialog(item),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                                    foregroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Link', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _parsedItems.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          if (_selectedCount > 0) _buildCartSummaryBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add_check_rounded, size: 64, color: Colors.purple.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'No items parsed yet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Type or record a grocery list above to match products automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _loadExample,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.purpleAccent),
                foregroundColor: Colors.purpleAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('TRY AN EXAMPLE LIST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummaryBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_selectedCount matched items', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Total: ₹${_totalPrice.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 180,
            child: CustomButton(
              text: 'ADD TO BAG',
              onPressed: _addSelectedToCart,
            ),
          ),
        ],
      ),
    );
  }
}
