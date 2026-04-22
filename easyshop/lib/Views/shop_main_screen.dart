import 'package:easyshop/Views/shop_add_product_page.dart';
import 'package:easyshop/Views/shop_home_page.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/auth.dart';
import 'package:flutter/material.dart';

class ShopMainScreen extends StatefulWidget {
  const ShopMainScreen({super.key});

  @override
  State<ShopMainScreen> createState() => _ShopMainScreenState();
}

class _ShopMainScreenState extends State<ShopMainScreen> {
  int selectedIndex = 0;
  final List pages = [
    const ShopHomePage(),
    const ShopAddProductPage(),
    const ShopProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 140,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/icons/logo_app.png',
              height: 120,
            ),
            const Spacer(),
            Text(
              selectedIndex == 0 ? "My Shop" : (selectedIndex == 1 ? "Add Product" : "Profile"),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selectedIndex == 0 ? Icons.storefront : (selectedIndex == 1 ? Icons.add_box_outlined : Icons.person),
              color: AppColors.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 15),
          ],
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.black45,
        backgroundColor: AppColors.secondaryColor,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "My Shop",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: "Add Product",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}

class ShopProfileScreen extends StatelessWidget {
  const ShopProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => Auth().signOut(),
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
      ),
    );
  }
}
