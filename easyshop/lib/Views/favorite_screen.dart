import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/Provider/favorite_provider.dart';
import 'package:easyshop/Widgets/unit_conversion.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
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
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        centerTitle: true,
        title: const Text(
          "Favorite",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      ),
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
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text("Error loading favorites"),
          );
        }
        var favoriteItems = 
          snapshot.data!.data() as Map<String, dynamic>?;

          if(favoriteItems == null){
            return const Center(child: Text("No data available for this favorite."),
            );
          }
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15, vertical: 8),
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
                              favoriteItems['image'],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            favoriteItems['name'], 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "\$${favoriteItems['price']}/${getUnit(favoriteItems['category'])}",
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
              Positioned(
                top: 50,
                right: 35,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      provider.toggleFavorite(favoriteItems);
                    });
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