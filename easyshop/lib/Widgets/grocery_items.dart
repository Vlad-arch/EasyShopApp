import 'package:easyshop/Provider/cart_provider.dart';
import 'package:easyshop/Provider/favorite_provider.dart';
import 'package:easyshop/Widgets/unit_conversion.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easyshop/utils/github_helper.dart';

class GroceryItems extends StatelessWidget { 
  final Map<String, dynamic> grocery;
  const GroceryItems({super.key, required this.grocery});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);
    CartProvider cartProvider = Provider.of<CartProvider>(context);
    return Container(
      width: 192,
      height: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Color(0xffF7FFF7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 0,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),   
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 173,
            width: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  GithubHelper.convertUrl(grocery['image']),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            grocery['name'],
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$",
                style: TextStyle(
                  fontSize: 22, 
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              Text(
                "${grocery['price']} /${getUnit(grocery['category'])}",
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryColor,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: GestureDetector( 
                    onTap: () {
                      provider.toggleFavorite(grocery);
                    },
                    child: Icon(
                      provider.isExist(grocery)
                        ? Icons.favorite
                        : Icons.favorite_border,
                      color: 
                        provider.isExist(grocery) ? Colors.red : Colors.black,
                      size: 27,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,                   
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(25),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: GestureDetector( 
                    onTap: () {
                      cartProvider.addCart(grocery);
                    },
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}