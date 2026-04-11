import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/Views/category_screen.dart';
import 'package:easyshop/Views/item_details_screen.dart';
import 'package:easyshop/Views/see_all_product.dart';
import 'package:easyshop/Widgets/cart_icon.dart';
import 'package:easyshop/Widgets/grocery_items.dart';
import 'package:easyshop/Widgets/my_search_bar.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:easyshop/utils/github_helper.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String category = '';
  List<Map<String,dynamic>> groceryItems = [];
  List<Map<String,dynamic>> groceryCategory = [];
  List<Map<String,dynamic>> filteredItems = [];
  List<Map<String,dynamic>> allProducts = [];
  
  bool isLoading = true;
  @override
  void initState(){
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchCategory();
    await fetchAllProducts(); // Carica tutti i prodotti per i suggerimenti
    if (groceryCategory.isNotEmpty) {
      category = groceryCategory[0]["name"]; 
      await filterProductByCategory(category);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchAllProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = 
        await FirebaseFirestore.instance.collection("product").get();
      setState(() {
        allProducts = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> fetchCategory() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = 
        await FirebaseFirestore.instance.collection("Category").get();
      setState(() {
        groceryCategory = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> filterProductByCategory(String selectedCategory) async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.
      instance
      .collection("product")
      .where('category',isEqualTo:selectedCategory)
      .get();
    setState(() {
        category = selectedCategory;
        groceryItems = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        filteredItems = groceryItems;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = groceryItems;
      });
    } else {
      setState(() {
        filteredItems = groceryItems
            .where((item) => item['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          children: [
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Text.rich(
                    TextSpan(
                      style: 
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                      children: [
                        TextSpan(text: "Hello,"),
                        TextSpan(
                          text: "Smith\n",
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                        TextSpan(
                          text: "What do you nedd",
                          style: TextStyle(fontSize: 17, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                CartIcon(),  
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                "Find the best prodocts!",
                style: TextStyle(
                  fontSize: 30, 
                  color: Colors.black, 
                  height: 1.2, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: MySearchBar(
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
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      const Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final selectedCategory = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryScreen(),
                            ),
                          );
                          if (selectedCategory != null && selectedCategory is String) {
                            filterProductByCategory(selectedCategory);
                          }
                        },
                        child: const Text(
                          "See All",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        groceryCategory.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              filterProductByCategory(
                                groceryCategory[index]['name'] ?? "Sconosciuto");                         
                            },
                            child: Container(
                              padding: 
                                const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width:
                                  category == (groceryCategory[index]['name'] ?? "Sconosciuto")
                                  ? 2
                                  : 1,
                              color: 
                                category == (groceryCategory[index]['name'] ?? "Sconosciuto") 
                                ? AppColors.primaryColor
                                : Colors.black,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 70, 
                                width: 70,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, 
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  image: DecorationImage(
                                    fit: BoxFit.contain,
                                    image: NetworkImage(
                                      GithubHelper.convertUrl(groceryCategory[index]['image']),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                groceryCategory[index]['name'] ?? "Sconosciuto",
                                style: TextStyle(
                                  fontWeight: category ==
                                        (groceryCategory[index]['name'] ?? "Sconosciuto")
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10,)
                            ],
                          ),  
                        ),                      
                      ),
                    ),                    
                  ),
                ),
                ),
                ),
                SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        const Text(
                          "Products",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const SeeAllProduct(),
                                ),
                              );
                          },
                          child: Text(
                            "See All",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.black,
                        )
                      ],
                    ),
                  ) 
              ],
            ),
            filteredItems.isEmpty 
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      "No products found", 
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                    child: Row(children:List.generate(
                      filteredItems.length, 
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only
                          (left: 15, 
                          top: 15, 
                          bottom: 15,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailsScreen(
                                    grocery: filteredItems[index],
                                  ),
                                ),
                              );
                            },
                            child: GroceryItems(
                              grocery: filteredItems[index],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),   
          ],
        ),
      ),
     ),
    );      
  }
}