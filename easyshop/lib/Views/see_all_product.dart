import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/Views/item_details_screen.dart';
import 'package:easyshop/Widgets/cart_icon.dart';
import 'package:easyshop/Widgets/grocery_items.dart';
import 'package:easyshop/Widgets/my_search_bar.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:flutter/material.dart';

class SeeAllProduct extends StatefulWidget {
  const SeeAllProduct({super.key});

  @override
  State<SeeAllProduct> createState() => _SeeAllProductState();
}

class _SeeAllProductState extends State<SeeAllProduct> {
  List<Map<String,dynamic>> groceryItems = [];
  List<Map<String,dynamic>> filterItems = [];  
  bool isLoading = true;
  @override
  void initState(){
    super.initState();
    fetchAllProduct();
  }

  Future<void> fetchAllProduct() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = 
        await FirebaseFirestore.instance.collection("Category").get();
      setState(() {
        groceryItems = snapshot.docs.map((docs) => docs.data()).toList();
        filterItems = groceryItems;
        isLoading = false;
      });
    } catch (e) {
      print(e.toString());
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
      backgroundColor: AppColors.secondaryColor,
        appBar: AppBar(
          backgroundColor: AppColors.secondaryColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "All Grocery Product",
            style: TextStyle(
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
        : SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MySearchBar(onSearch: searchfilterItems),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 720,
                    width: double.maxFinite,
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
                                    grocery: groceryItems[index],
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
            ),
        );
  }
}