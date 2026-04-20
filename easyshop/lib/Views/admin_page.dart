import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isSeeding = false;

  final List<Map<String, dynamic>> categories = [
    {"name": "Fruits", "image": "frutta.jpg"},
    {"name": "Vegetables", "image": "vegetables.jpeg"},
    {"name": "Meat", "image": "meat.jpeg"},
    {"name": "Dairy", "image": "dairy.jpg"},
    {"name": "Grains", "image": "grains.jpeg"},
    {"name": "Sweets", "image": "sweets.jpg"},
    {"name": "Fish", "image": "fish.jpeg"},
    {"name": "Bakery", "image": "grains.jpeg"},
    {"name": "Beverages", "image": "https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=500&q=80"},
    {"name": "Frozen Foods", "image": "https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500&q=80"},
  ];

  final List<Map<String, dynamic>> products = [
    {"name": "Apple", "price": 1.20, "image": "apple.jpeg", "category": "Fruits", "description": "Fresh red delicious apple.", "shop": "SuperShop Milano"},
    {"name": "Strawberry", "price": 3.50, "image": "strawberry.jpeg", "category": "Fruits", "description": "Sweet local strawberries.", "shop": "SuperShop Milano"},
    {"name": "Chicken breast", "price": 8.90, "image": "chicken.jpeg", "category": "Meat", "description": "Organic chicken breast from Roma.", "shop": "Meat Experts Roma"},
    {"name": "Beef Steak", "price": 15.50, "image": "https://images.unsplash.com/photo-1546248133-12832329b390?w=500&q=80", "category": "Meat", "description": "Premium Italian beef steak.", "shop": "Meat Experts Roma"},
    {"name": "Spinach", "price": 1.50, "image": "spinach.jpeg", "category": "Vegetables", "description": "Fresh green spinach.", "shop": "SuperShop Milano"},
    {"name": "Fresh Milk", "price": 1.80, "image": "https://images.unsplash.com/photo-1563636619-e910ef2a844b?w=500&q=80", "category": "Dairy", "description": "Fresh milk from Roman hills.", "shop": "Meat Experts Roma"},
    {"name": "Margherita Pizza", "price": 6.50, "image": "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80", "category": "Frozen Foods", "description": "Classic frozen pizza.", "shop": "Meat Experts Roma"},
    {"name": "Baguette", "price": 1.20, "image": "https://images.unsplash.com/photo-1597079910443-60c43fc4f729?w=500&q=80", "category": "Bakery", "description": "Crispy French-style baguette.", "shop": "Meat Experts Roma"},
  ];

  final List<Map<String, dynamic>> stores = [
    {
      "name": "SuperShop Milano", 
      "position": "Via Roma 1, Milano, Italia",
      "lat": 45.4642,
      "lng": 9.1900
    },
    {
      "name": "Meat Experts Roma", 
      "position": "Via del Corso 1, Roma, Italia",
      "lat": 41.9028,
      "lng": 12.4964
    },
  ];

  Future<void> seedShops() async {
    setState(() => isSeeding = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var shop in stores) {
        final docRef = FirebaseFirestore.instance.collection("shops").doc(shop['name']);
        batch.set(docRef, shop);
      }
      await batch.commit();
      _showSuccess("Shops seeded successfully!");
    } catch (e) {
      _showError("Error seeding shops: $e");
    } finally {
      if (mounted) setState(() => isSeeding = false);
    }
  }

  Future<void> seedCategories() async {
    setState(() => isSeeding = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var cat in categories) {
        // Use normalized name as ID to prevent duplicates
        final docRef = FirebaseFirestore.instance.collection("Category").doc(cat['name']);
        batch.set(docRef, cat);
      }
      await batch.commit();
      _showSuccess("Categories seeded successfully!");
    } catch (e) {
      _showError("Error seeding categories: $e");
    } finally {
      if (mounted) setState(() => isSeeding = false);
    }
  }

  Future<void> seedProducts() async {
    setState(() => isSeeding = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var prod in products) {
        // Create a unique ID based on name and category to prevent duplicates
        final String id = "${prod['name']}_${prod['category']}".toLowerCase().replaceAll(" ", "_");
        final docRef = FirebaseFirestore.instance.collection("product").doc(id);
        batch.set(docRef, prod);
      }
      await batch.commit();
      _showSuccess("Products seeded successfully!");
    } catch (e) {
      _showError("Error seeding products: $e");
    } finally {
      if (mounted) setState(() => isSeeding = false);
    }
  }

  Future<void> cleanDuplicates() async {
    setState(() => isSeeding = true);
    try {
      // 1. Merge "Snacks" into "Sweets"
      await _mergeCategories("Snacks", "Sweets");
      
      // 2. Perform normal cleanup
      int deletedCategories = await _removeDuplicatesFromCollection("Category", ["name"]);
      int deletedProducts = await _removeDuplicatesFromCollection("product", ["name", "category"]);
      
      _showSuccess("Cleaned up! Removed $deletedCategories categories and $deletedProducts products.");
    } catch (e) {
      _showError("Error cleaning duplicates: $e");
    } finally {
      if (mounted) setState(() => isSeeding = false);
    }
  }

  Future<void> _mergeCategories(String oldCat, String newCat) async {
    final productsRef = FirebaseFirestore.instance.collection("product");
    final categoryRef = FirebaseFirestore.instance.collection("Category");
    
    // Update products
    final productsSnapshot = await productsRef.where("category", isEqualTo: oldCat).get();
    if (productsSnapshot.docs.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in productsSnapshot.docs) {
        batch.update(doc.reference, {"category": newCat});
      }
      await batch.commit();
    }
    
    // Delete old category
    await categoryRef.doc(oldCat).delete();
  }

  Future<int> _removeDuplicatesFromCollection(String collectionPath, List<String> keys) async {
    final collection = FirebaseFirestore.instance.collection(collectionPath);
    final snapshot = await collection.get();
    final Map<String, bool> seen = {};
    final batch = FirebaseFirestore.instance.batch();
    int deletedCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      // Generate a unique key based on the specified fields
      final String key = keys.map((k) => data[k]?.toString().toLowerCase().trim() ?? "").join("_");
      
      if (seen.containsKey(key)) {
        batch.delete(doc.reference);
        deletedCount++;
      } else {
        seen[key] = true;
      }
    }
    
    if (deletedCount > 0) {
      await batch.commit();
    }
    return deletedCount;
  }

  Future<void> clearData() async {
    setState(() => isSeeding = true);
    try {
      await _deleteCollection("Category");
      await _deleteCollection("product");
      _showSuccess("All data cleared successfully!");
    } catch (e) {
      _showError("Error clearing data: $e");
    } finally {
      if (mounted) setState(() => isSeeding = false);
    }
  }

  Future<void> _deleteCollection(String collectionPath) async {
    final collection = FirebaseFirestore.instance.collection(collectionPath);
    final snapshots = await collection.get();
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    return batch.commit();
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Data?"),
        content: const Text("This will delete all categories and products from Firestore. This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              clearData();
            },
            child: const Text("Delete Everything", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Seeding"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 100, color: AppColors.primaryColor),
                const SizedBox(height: 40),
                const Text(
                  "Database Management",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Populate or reset your Firestore database collections.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),
                if (isSeeding)
                  const CircularProgressIndicator()
                else ...[
                  _buildButton(
                    onPressed: seedShops,
                    icon: Icons.store,
                    label: "Seed Shops",
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    onPressed: seedCategories,
                    icon: Icons.category,
                    label: "Seed Categories",
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    onPressed: seedProducts,
                    icon: Icons.shopping_bag,
                    label: "Seed Products",
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    onPressed: cleanDuplicates,
                    icon: Icons.cleaning_services,
                    label: "Clean Duplicates",
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 20),
                  _buildButton(
                    onPressed: _confirmClearData,
                    icon: Icons.delete_forever,
                    label: "Clear All Data",
                    color: Colors.redAccent,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
