import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/utils/github_helper.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> groceryCategory = [
      {"name": "Vegetables", "image": "melanzane.jpeg"},
      {"name": "Fruits", "image": "mela.jpeg"},
      {"name": "Meat", "image": "carne.jpeg"},
      {"name": "Dairy", "image": "uova.jpeg"},
      {"name": "Beverages", "image": "bibita.jpeg"},
      {"name": "Snacks", "image": "snack.jpeg"},
    ];

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "All Categories",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: GridView.builder(
          itemCount: groceryCategory.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Return to home and select this category
                Navigator.pop(context, groceryCategory[index]['name']);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: NetworkImage(
                            GithubHelper.convertUrl(groceryCategory[index]['image']),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      groceryCategory[index]['name'] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
