import 'package:easyshop/utils/colors.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 100,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'EasyShop',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your Neighborhood Marketplace',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Welcome to EasyShop, the innovative e-commerce platform designed to bring your local community closer together. Our mission is to empower local businesses and provide customers with a seamless, proximity-based shopping experience.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'What we offer:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildFeatureItem(
              Icons.location_on_outlined,
              'Proximity Filtering',
              'Find products from stores within a 150km radius of your location.',
            ),
            _buildFeatureItem(
              Icons.storefront_outlined,
              'Support Local',
              'Easy registration for local shops to become partners and reach nearby customers.',
            ),
            _buildFeatureItem(
              Icons.flash_on_outlined,
              'Seamless Experience',
              'Quick browsing, diverse categories, and an easy-to-use interface.',
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                '© 2026 EasyShop Team. All rights reserved.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
