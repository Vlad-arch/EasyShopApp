import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/Provider/favorite_provider.dart';
import 'package:easyshop/Views/item_details_screen.dart';
import 'package:easyshop/Widgets/unit_conversion.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/utils/github_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatefulWidget{
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
      final provider = Provider.of<FavoriteProvider>(context);
      final favoriteItems = provider.favorites;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: favoriteItems.isEmpty 
      ? const Center(
        child: Text(
          "No Favorite yet",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    : ListView.builder(
      itemCount: favoriteItems.length,
      itemBuilder: (context, index) {
      String favorite = favoriteItems[index];

      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
        .collection("product")
        .doc(favorite)
        .get(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print("Favorite error for ID $favorite: ${snapshot.error}");
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          print("Favorite not found in 'product' collection: $favorite");
          return const SizedBox.shrink(); // Non mostriamo nulla se il prodotto è sparito
        }
        var productData = 
          snapshot.data!.data() as Map<String, dynamic>?;

        if(productData == null){
          return const Center(child: Text("No data available for this favorite."),
          );
        }
        // Assicuriamoci che l'ID sia nel map per il toggle
        productData['id'] = snapshot.data!.id;
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => ItemDetailsScreen(
                          grocery: productData,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                GithubHelper.convertUrl(productData['image']),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productData['name'] ?? "Unknown", 
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "€${productData['price'] ?? '0.00'}/${getUnit(productData['category'])}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),  
              ),
              Positioned(
                top: 50,
                right: 35,
                child: GestureDetector(
                  onTap: () {
                    provider.toggleFavorite(productData);
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 25,
                  ),
                ),
                )
              ],
            );
          });
        },
      ),
    );
  } 
}