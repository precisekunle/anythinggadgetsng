import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_products_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Phones', 'icon': Icons.phone_android},
    {'name': 'Laptops', 'icon': Icons.laptop},
    {'name': 'Audio', 'icon': Icons.headphones},
    {'name': 'Wearables', 'icon': Icons.watch},
    {'name': 'Cameras', 'icon': Icons.camera_alt},
    {'name': 'Gaming', 'icon': Icons.videogame_asset},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Categories",
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryProductsScreen(categoryName: category['name']),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category['icon'], size: 40, color: const Color(0xFF007AFF)),
                  const SizedBox(height: 12),
                  Text(
                    category['name'],
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
