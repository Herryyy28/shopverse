import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<String> _recentSearches = ['Milk', 'Bread', 'Smart Watch', 'Shoes', 'Headphones'];
  final List<String> _trendingSearches = ['iPhone 15', 'Winter Wear', 'Laptops', 'Face Wash'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recentSearches.isNotEmpty) ...[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Clear All', style: TextStyle(color: Colors.deepPurple, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches.map((search) => _buildSearchChip(search)).toList(),
              ),
              const SizedBox(height: 24),
            ],
            const Text('Trending Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Column(
              children: _trendingSearches.map((search) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.trending_up, color: Colors.grey),
                title: Text(search),
                trailing: const Icon(Icons.north_west, size: 18, color: Colors.grey),
                onTap: () {},
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    );
  }
}
