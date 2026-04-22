import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/Views/item_details_screen.dart';
import 'package:easyshop/Widgets/grocery_items.dart';
import 'package:easyshop/Widgets/my_search_bar.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/auth.dart';
import 'package:flutter/material.dart';

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({super.key});

  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  String category = 'All';
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<String> categories = ['All'];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShopProducts();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("Category").get();
      if (mounted) {
        setState(() {
          categories = ['All'] + snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchShopProducts() async {
    setState(() => isLoading = true);
    try {
      final shopId = Auth().currentUser?.uid;
      if (shopId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection("product")
            .where("shop", isEqualTo: shopId)
            .get();

        final products = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        if (mounted) {
          setState(() {
            allProducts = products;
            filteredItems = products;
          });
        }
      }
    } catch (e) {
      print("Error fetching shop products: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void filterByCategory(String selectedCategory) {
    setState(() {
      category = selectedCategory;
      if (selectedCategory == 'All') {
        filteredItems = allProducts;
      } else {
        filteredItems = allProducts.where((item) => item['category'] == selectedCategory).toList();
      }
    });
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = category == 'All' 
            ? allProducts 
            : allProducts.where((item) => item['category'] == category).toList();
      });
    } else {
      setState(() {
        filteredItems = allProducts
            .where((item) => (item['name'] as String).toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Manage Your Inventory",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          MySearchBar(
            suggestions: allProducts,
            onSearch: searchProducts,
            onSuggestionSelected: (product) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailsScreen(grocery: product),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = categories[index] == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(categories[index]),
                    selected: isSelected,
                    onSelected: (val) => filterByCategory(categories[index]),
                    selectedColor: AppColors.primaryColor.withOpacity(0.3),
                    checkmarkColor: AppColors.primaryColor,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? const Center(child: Text("No products found in your shop."))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailsScreen(grocery: filteredItems[index]),
                                ),
                              );
                            },
                            child: GroceryItems(grocery: filteredItems[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
