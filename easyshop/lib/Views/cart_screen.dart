import 'package:easyshop/Provider/Model/cart_model.dart';
import 'package:easyshop/Provider/cart_provider.dart';
import 'package:easyshop/Views/Widgets/cart_items.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = Provider.of<CartProvider>(context);
    List<CartModel> carts = cartProvider.carts.reversed.toList();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "My Cart",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: size.height * 0.5,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(
                carts.length, 
                (index) => SizedBox(
                  height: 100,
                  width: size.width,
                  child: CartItems(
                    cart: carts[index]
                  ),
                ),
              ),
            ),
            ),
          ),
        ),
      ),
      ),
      bottomSheet: carts.isEmpty 
        ? Container(
          color: AppColors.secondaryColor,
          child: Center(
            child: Text("Cart empty"),
          ),
        )
      : Container(
          color: AppColors.secondaryColor,
          height: size.height * 0.345,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "\$${cartProvider.totalCart().toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                       fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: true, 
                      onChanged: null,
                      activeColor: AppColors.primaryColor,
                    ),
                    Text(
                      "Delevery charge",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "\$4.99", 
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Checkbox(
                      value: true, 
                      onChanged: null,
                      activeColor: AppColors.primaryColor,
                    ),
                    const Text(
                      "Eco-friendly Bag",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "\$${(carts.length*0.1).toStringAsFixed(2)}", 
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: size.width*0.75,
                  child: const Text("Buy paper bags to reduce plastic",
                  style: TextStyle(
                    fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Price",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "\$${(cartProvider.totalCart() +4.99 + 0.1 * carts.length).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                       fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        spreadRadius: 2, 
                        blurRadius: 7,
                        offset: const Offset(0, 2),
                      )
                    ]
                  ),
                  child: const Text(
                    "Process to checkout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
              ],             
            ),
          ),
      ),
    );
  }
}