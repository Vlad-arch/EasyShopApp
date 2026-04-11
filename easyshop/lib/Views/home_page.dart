import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/Views/item_details_screen.dart';
import 'package:easyshop/Views/see_all_product.dart';
import 'package:easyshop/Widgets/cart_icon.dart';
import 'package:easyshop/Widgets/grocery_items.dart';
import 'package:easyshop/Widgets/my_search_bar.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easyshop/utils/colors.dart';
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
  
  bool isLoading = true;
  @override
  void initState(){
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchCategory();
    if (groceryCategory.isNotEmpty) {
      category = groceryCategory[0]["name"]; 
      await filterProductByCategory(category);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCategory() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = 
        await FirebaseFirestore.instance.collection("Category").get();
      setState(() {
        groceryCategory = snapshot.docs.map((docs) => docs.data()).toList();
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
        groceryItems = snapshot.docs.map((docs) => docs.data()).toList();
      });
    } catch (e) {
      print(e.toString());
    }
    finally{
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
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
                onSearch: (p) {},
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Text(
                        "Caregory",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
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
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, 
                                  color: AppColors.primaryColor,
                                  image: DecorationImage(
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
                        Text(
                          "Caregory",
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
            groceryItems.isEmpty 
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      "No products available in this category", 
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
                      groceryItems.length, 
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
                                    grocery: groceryItems[index],
                                  ),
                                ),
                              );
                            },
                            child: GroceryItems(
                              grocery: groceryItems[index],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),   
          ],
        ),
      )
    );      
  }
}