import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/utils/github_helper.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> groceryCategory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategory();
  }

  Future<void> fetchCategory() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirebaseFirestore.instance.collection("Category").get();
      setState(() {
        groceryCategory = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "All Categories",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15),
              child: GridView.builder(
                itemCount: groceryCategory.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, groceryCategory[index]['name']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: NetworkImage(
                                  GithubHelper.convertUrl(groceryCategory[index]['image']),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            groceryCategory[index]['name'] ?? "Unknown",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
