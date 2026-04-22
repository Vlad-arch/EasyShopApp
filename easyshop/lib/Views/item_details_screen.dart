import 'package:easyshop/Provider/cart_provider.dart';
import 'package:easyshop/Views/cart_screen.dart';
import 'package:easyshop/Provider/favorite_provider.dart';
import 'package:easyshop/Widgets/cart_icon.dart';
import 'package:easyshop/Widgets/unit_conversion.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/utils/github_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemDetailsScreen extends StatelessWidget{
  final Map<String, dynamic> grocery;
  const ItemDetailsScreen({super.key, required this.grocery});

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Product Details",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: () {
                  provider.toggleFavorite(grocery);
                },
                icon: Icon(
                  provider.isExist(grocery)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: provider.isExist(grocery) ? Colors.red : Colors.black,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {},
            icon: const CartIcon(),
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              GithubHelper.convertUrl(grocery['image']),
              height: 350,
              width: 350,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              grocery['name'] ?? "Unknown Product",
              style: const TextStyle(
                fontSize: 27,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.stars,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 5),
                Text(
                  (grocery['rating'] ?? 0.0).toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "€${grocery['price'] ?? '0.00'} /${getUnit(grocery['category'])}",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    ),
                  )
                ],
              ),
              Text(
                  grocery['category'] ?? "No Category",
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
              ),
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 15, bottom: 5),
                  child: Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (grocery['description'] is List)
                    ? (grocery['description'] as List<dynamic>)
                        .map((item) => Text(
                              item.toString(),
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                              ),
                            ))
                        .toList()
                    : [
                        Text(
                          grocery['description']?.toString() ?? "No description available",
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                          ),
                        )
                      ]),
              ),
              SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          cartProvider.addCart(grocery);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 130,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            color: AppColors.primaryColor,
                          ),
                          child: const Text(
                            "Buy",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 180,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          color: AppColors.primaryColor
                        ),
                      child: GestureDetector(
                        onTap: () {
                          cartProvider.addCart(grocery);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${grocery['name']} added to cart!"),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primaryColor,
                            ),
                          );
                        },
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ), 
                      )                    
                    ],
                  )   
                ],
              ),
          ],
        ),      
      ),
    );
  }
}