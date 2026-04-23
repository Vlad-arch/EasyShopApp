import 'package:easyshop/Provider/cart_provider.dart';
import 'package:easyshop/Provider/favorite_provider.dart';
import 'package:easyshop/Widgets/unit_conversion.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easyshop/utils/github_helper.dart';

class GroceryItems extends StatelessWidget { 
  final Map<String, dynamic> grocery;
  final bool isAdmin;
  const GroceryItems({super.key, required this.grocery, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);
    CartProvider cartProvider = Provider.of<CartProvider>(context);
    
    final int stock = grocery['stock'] ?? 0;
    final bool isOutOfStock = stock <= 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            AppColors.backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 0,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),   
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
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
                if (isAdmin && isOutOfStock)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "SOLD OUT",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
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
              const Text(
                '€',
                style: TextStyle(
                  fontSize: 22, 
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              Text(
                "${grocery['price'] ?? '0.00'} /${getUnit(grocery['category'])}",
                style: const TextStyle(
                  fontSize: 18, 
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              )
            ],
          ),
          if (isAdmin)
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
               child: Container(
                 width: double.infinity,
                 padding: const EdgeInsets.symmetric(vertical: 6),
                 decoration: BoxDecoration(
                   color: isOutOfStock ? Colors.red.withOpacity(0.1) : AppColors.primaryColor.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(15),
                   border: Border.all(color: isOutOfStock ? Colors.red : AppColors.primaryColor, width: 1),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(
                       isOutOfStock ? Icons.error_outline : Icons.inventory_2_outlined,
                       size: 16,
                       color: isOutOfStock ? Colors.red : AppColors.primaryColor,
                     ),
                     const SizedBox(width: 5),
                     Text(
                       isOutOfStock ? "Out of Stock" : "Stock: $stock",
                       style: TextStyle(
                         fontSize: 14,
                         fontWeight: FontWeight.bold,
                         color: isOutOfStock ? Colors.red : AppColors.primaryColor,
                       ),
                     ),
                   ],
                 ),
               ),
             )
          else
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
                    decoration: BoxDecoration(
                      color: isOutOfStock ? Colors.grey : AppColors.primaryColor,                   
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(25),
                        topLeft: Radius.circular(30),
                      ),
                    ),
                    child: GestureDetector( 
                      onTap: isOutOfStock ? null : () {
                        cartProvider.addCart(grocery);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${grocery['name']} added to cart!"),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.primaryColor,
                          ),
                        );
                      },
                      child: Icon(
                        isOutOfStock ? Icons.block : Icons.shopping_cart,
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