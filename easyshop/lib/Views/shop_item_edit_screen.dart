import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/auth.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/utils/github_helper.dart';
import 'package:flutter/material.dart';

class ShopItemEditScreen extends StatefulWidget {
  final Map<String, dynamic> grocery;
  const ShopItemEditScreen({super.key, required this.grocery});

  @override
  State<ShopItemEditScreen> createState() => _ShopItemEditScreenState();
}

class _ShopItemEditScreenState extends State<ShopItemEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.grocery['description']?.toString() ?? '');
    _priceController = TextEditingController(text: widget.grocery['price']?.toString() ?? '0.0');
    _stockController = TextEditingController(text: widget.grocery['stock']?.toString() ?? '0');
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final String currentUid = Auth().currentUser!.uid;
      final bool isAlreadyMyShop = widget.grocery['shop'] == currentUid;

      if (isAlreadyMyShop) {
        // 1. Update existing product
        final String productId = widget.grocery['id'];
        await FirebaseFirestore.instance.collection('product').doc(productId).update({
          'description': _descriptionController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'stock': int.parse(_stockController.text.trim()),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // 2. Adopt/Clone logic
        // Check if a clone for this shop ALREADY exists for this original
        final existingCloneQuery = await FirebaseFirestore.instance
            .collection('product')
            .where('shop', isEqualTo: currentUid)
            .where('clonedFrom', isEqualTo: widget.grocery['id'])
            .limit(1)
            .get();

        if (existingCloneQuery.docs.isNotEmpty) {
          // Update the existing clone instead of creating a new one
          await existingCloneQuery.docs.first.reference.update({
            'description': _descriptionController.text.trim(),
            'price': double.parse(_priceController.text.trim()),
            'stock': int.parse(_stockController.text.trim()),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Create NEW clone
          await FirebaseFirestore.instance.collection('product').add({
            'name': widget.grocery['name'],
            'image': widget.grocery['image'],
            'category': widget.grocery['category'],
            'rating': widget.grocery['rating'] ?? 0.0,
            'description': _descriptionController.text.trim(),
            'price': double.parse(_priceController.text.trim()),
            'stock': int.parse(_stockController.text.trim()),
            'shop': currentUid,
            'createdAt': FieldValue.serverTimestamp(),
            'clonedFrom': widget.grocery['id'],
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product updated successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating product: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        title: const Text("Edit Product", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    GithubHelper.convertUrl(widget.grocery['image']),
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  widget.grocery['name'] ?? "Unknown Product",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: "Enter product description...",
                ),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Price (€)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.euro),
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Stock", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.inventory_2_outlined),
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : _saveChanges,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
