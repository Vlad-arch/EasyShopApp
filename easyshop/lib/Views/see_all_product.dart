import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/Views/item_details_screen.dart';
import 'package:easyshop/Widgets/cart_icon.dart';
import 'package:easyshop/Widgets/grocery_items.dart';
import 'package:easyshop/Widgets/my_search_bar.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/utils/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class SeeAllProduct extends StatefulWidget {
  final String? category;
  const SeeAllProduct({super.key, this.category});

  @override
  State<SeeAllProduct> createState() => _SeeAllProductState();
}

class _SeeAllProductState extends State<SeeAllProduct> {
  List<Map<String,dynamic>> groceryItems = [];
  List<Map<String,dynamic>> filterItems = [];  
  bool isLoading = true;
  Position? userPosition;
  Map<String, Map<String, dynamic>> shopData = {}; // shopName -> full data including lat/lng

  @override
  void initState(){
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      userPosition = await LocationService().getUserPosition();
    } catch (e) {
      print("Could not fetch user position in SeeAllProduct: $e");
    }
    await fetchShops();
    await fetchAllProduct();
  }

  Future<void> fetchShops() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("shops").get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        shopData[doc.id] = data;
      }
    } catch (e) {
      print("Error fetching shops in SeeAllProduct: $e");
    }
  }

  Future<void> fetchAllProduct() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = 
        await FirebaseFirestore.instance.collection("product").get();
      
      List<Map<String, dynamic>> products = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Category Filter (if applicable)
        if (widget.category != null && widget.category!.isNotEmpty) {
          if (data['category'] != widget.category) continue;
        }

        // Proximity Filter
        if (userPosition != null && data['shop'] != null) {
          final shop = shopData[data['shop']];
          if (shop != null) {
            // Check if we have pre-defined coordinates first (to bypass failing Geocoding API)
            if (shop['lat'] != null && shop['lng'] != null) {
              double distance = Geolocator.distanceBetween(
                userPosition!.latitude,
                userPosition!.longitude,
                (shop['lat'] as num).toDouble(),
                (shop['lng'] as num).toDouble(),
              );
              if (distance > 150000) continue; // Skip if > 150km
            } else {
              // Fallback to dynamic geocoding
              final address = shop['position'];
              if (address != null && address.isNotEmpty) {
                try {
                  bool isNearby = await LocationService().isStoreNearby(
                    userPosition: userPosition!,
                    shopAddress: address,
                    radiusKm: 150.0,
                  );
                  if (!isNearby) continue;
                } catch (e) {
                  continue;
                }
              } else {
                continue; // No address or coordinates
              }
            }
          } else {
            continue; // Shop document missing
          }
        } else {
          continue; // User position or product shop missing
        }
        products.add(data);
      }

      setState(() {
        groceryItems = products;
        filterItems = groceryItems;
      });
    } catch (e) {
      print("Error fetching products in SeeAllProduct: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchfilterItems(String query) {
    if(query.isEmpty) {
      setState(() {
        filterItems = groceryItems;
      });
    } else {
      setState(() {
        filterItems = groceryItems.where((item) {
          return item['name']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.category != null && widget.category!.isNotEmpty 
                ? "Products in ${widget.category}" 
                : "All Grocery Product",
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {}, 
              icon: const CartIcon(),
            ),
            const SizedBox(width: 15),
          ],
        ),
        body: isLoading 
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : groceryItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
          : SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MySearchBar(
                    suggestions: groceryItems,
                    onSearch: searchfilterItems,
                    onSuggestionSelected: (product) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailsScreen(grocery: product),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      itemCount: filterItems.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          crossAxisSpacing: 15, 
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.662,
                        ),
                        itemBuilder: (context, index){
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailsScreen(
                                    grocery: filterItems[index],
                                  ),
                                ),
                              );
                            },
                            child: GroceryItems(
                              
                              grocery: filterItems[index],
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
        );
  }
}