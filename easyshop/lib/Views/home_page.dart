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
import 'package:easyshop/auth.dart';
import 'package:easyshop/utils/location_service.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String category = '';
  List<Map<String,dynamic>> groceryItems = [];
  List<Map<String,dynamic>> groceryCategory = [];
  List<Map<String,dynamic>> filteredItems = [];
  List<Map<String,dynamic>> allProducts = [];
  Map<String, Position> shopCoordinates = {};
  Position? userPosition;
  
  bool isLoading = true;
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh location and products when app is reopened
      fetchData();
    }
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      // 1. Concurrent fetching to save time
      await Future.wait([
        fetchUserPosition(),
        fetchShopsAndGeocode(),
        fetchCategory(),
      ]);
      
      // 2. Fetch products (filtering happens inside based on available data)
      await fetchAllProducts();
      
      if (groceryCategory.isNotEmpty) {
        category = groceryCategory[0]["name"]; 
        await filterProductByCategory(category);
      }
    } catch (e) {
      print("Error in fetchData: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchUserPosition() async {
    try {
      userPosition = await LocationService().getUserPosition();
      print("User position: $userPosition");
    } catch (e) {
      print("Could not fetch user position: $e");
      userPosition = null; // Ensure it's null for fallback logic
    }
  }

  Future<void> fetchShopsAndGeocode() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("shops").get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Priority: Use hardcoded coordinates from Firestore to bypass local geocoding failures
        if (data['lat'] != null && data['lng'] != null) {
          shopCoordinates[doc.id] = Position(
            latitude: (data['lat'] as num).toDouble(),
            longitude: (data['lng'] as num).toDouble(),
            timestamp: DateTime.now(),
            accuracy: 0, altitude: 0, heading: 0, speed: 0, 
            speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
          );
          continue; // Skip geocoding if we have coords
        }

        final address = data['position'];
        if (address != null) {
          final loc = await LocationService().getCoordinatesFromAddress(address);
          if (loc != null) {
            shopCoordinates[doc.id] = Position(
              latitude: loc.latitude,
              longitude: loc.longitude,
              timestamp: DateTime.now(),
              accuracy: 0, altitude: 0, heading: 0, speed: 0,
              speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
            );
          }
        }
      }
    } catch (e) {
      print("Error fetching shops or geocoding: $e");
    }
  }

  Future<void> fetchAllProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = 
        await FirebaseFirestore.instance.collection("product").get();
      
      List<Map<String, dynamic>> products = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Proximity Filter
        if (userPosition != null && data['shop'] != null) {
          final shopPos = shopCoordinates[data['shop']];
          if (shopPos != null) {
            double distance = Geolocator.distanceBetween(
              userPosition!.latitude, 
              userPosition!.longitude, 
              shopPos.latitude, 
              shopPos.longitude
            );
            if (distance > 150000) {
              continue; // Skip if > 150km
            }
          } else {
            // No coordinates for shop? Treat as far/missing
            continue;
          }
        } else {
          // No user position or no shop assigned? Skip to trigger "No products in area"
          continue;
        }
        
        products.add(data);
      }

      setState(() {
        allProducts = products;
      });
    } catch (e) {
      print("Error fetching products: $e");
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
      category = selectedCategory;
      // Filter from the already proximity-filtered allProducts list
      groceryItems = allProducts.where((item) => item['category'] == selectedCategory).toList();
      filteredItems = groceryItems;
      isLoading = false;
    });
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(Auth().currentUser?.uid).snapshots(),
                    builder: (context, snapshot) {
                      String name = "User";
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        name = data?['name'] ?? "User";
                      }
                      return Text.rich(
                        TextSpan(
                          style: 
                            const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                          children: [
                            const TextSpan(text: "Hello, "),
                            TextSpan(
                              text: "$name\n",
                              style: const TextStyle(color: AppColors.primaryColor),
                            ),
                            const TextSpan(
                              text: "What do you need?",
                              style: TextStyle(fontSize: 17, color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }
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
                                builder: (context) => SeeAllProduct(category: category),
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
            allProducts.isEmpty && !isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Text(
                      "We're sorry, but there are no products available in your area",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : filteredItems.isEmpty && !isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        "No products found in this category", 
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
                            child: SizedBox(
                              width: 192,
                              height: 290,
                              child: GroceryItems(
                                grocery: filteredItems[index],
                              ),
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