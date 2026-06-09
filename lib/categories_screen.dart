import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Grocery', 'icon': Icons.fastfood, 'color': Colors.green},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.blue},
    {'name': 'Electronics', 'icon': Icons.electrical_services, 'color': Colors.orange},
    {'name': 'Home', 'icon': Icons.home, 'color': Colors.brown},
    {'name': 'Beauty', 'icon': Icons.health_and_safety, 'color': Colors.pink},
    {'name': 'Toys', 'icon': Icons.toys, 'color': Colors.red},
    {'name': 'Sports', 'icon': Icons.sports_basketball, 'color': Colors.indigo},
    {'name': 'Automotive', 'icon': Icons.directions_car, 'color': Colors.blueGrey},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: category['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: category['color'].withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Icon(category['icon'], color: category['color'], size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category['name'],
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ],
          );
        },
      ),
    );
  }
}
