import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/Views/shop_item_edit_screen.dart';
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
  bool showMyShopOnly = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchProducts();
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

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection("product").get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      if (mounted) {
        setState(() {
          allProducts = products;
          applyFilters();
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void applyFilters() {
    final shopId = Auth().currentUser?.uid;
    
    // Identify IDs of products that have already been cloned by this shop
    final Set<String> clonedOriginalIds = allProducts
        .where((item) => item['shop'] == shopId && item['clonedFrom'] != null)
        .map((item) => item['clonedFrom'] as String)
        .toSet();

    setState(() {
      filteredItems = allProducts.where((item) {
        // Shadowing logic: If this is a global product (not mine) 
        // AND I have already cloned it, HIDE the original.
        bool isGlobal = item['shop'] != shopId;
        if (isGlobal && clonedOriginalIds.contains(item['id'])) {
          return false;
        }

        // Filter by category
        bool matchesCategory = category == 'All' || item['category'] == category;
        
        // Filter by search query
        bool matchesSearch = searchQuery.isEmpty || 
                            (item['name'] as String).toLowerCase().contains(searchQuery.toLowerCase());
        
        // Filter by "My Shop"
        bool matchesMyShop = !showMyShopOnly || item['shop'] == shopId;

        return matchesCategory && matchesSearch && matchesMyShop;
      }).toList();

      // Sort: My products first
      filteredItems.sort((a, b) {
        bool aIsMine = a['shop'] == shopId;
        bool bIsMine = b['shop'] == shopId;
        if (aIsMine && !bIsMine) return -1;
        if (!aIsMine && bIsMine) return 1;
        return 0; // Maintain relative order for same ownership
      });
    });
  }

  void filterByCategory(String selectedCategory) {
    category = selectedCategory;
    applyFilters();
  }

  void searchProducts(String query) {
    searchQuery = query;
    applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Market Inventory",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              FilterChip(
                label: const Text("My Products"),
                selected: showMyShopOnly,
                onSelected: (val) {
                  setState(() {
                    showMyShopOnly = val;
                    applyFilters();
                  });
                },
                selectedColor: AppColors.primaryColor.withOpacity(0.3),
                checkmarkColor: AppColors.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 15),
          MySearchBar(
            suggestions: allProducts,
            onSearch: searchProducts,
            onSuggestionSelected: (product) async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopItemEditScreen(grocery: product),
                ),
              );
              if (updated == true) fetchProducts();
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.tune, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
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
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? const Center(child: Text("No products found for this selection."))
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
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShopItemEditScreen(grocery: filteredItems[index]),
                                ),
                              );
                              if (updated == true) fetchProducts();
                            },
                            child: GroceryItems(grocery: filteredItems[index], isAdmin: true),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
