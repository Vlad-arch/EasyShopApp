import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/Provider/cart_provider.dart';
import 'package:easyshop/auth.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/utils/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  Future<void> _showEditDialog({
    required BuildContext context,
    required String title,
    required String currentValue,
    required String fieldName,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) async {
    final TextEditingController controller = TextEditingController(text: currentValue);
    bool isLoadingLocation = false;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    decoration: InputDecoration(
                      hintText: hintText,
                      suffixIcon: fieldName == 'address' 
                        ? IconButton(
                            icon: isLoadingLocation 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location, color: AppColors.primaryColor),
                            onPressed: isLoadingLocation ? null : () async {
                              setDialogState(() => isLoadingLocation = true);
                              try {
                                final address = await LocationService().getCurrentAddress();
                                if (address != null) {
                                  controller.text = address;
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Location error: $e")),
                                  );
                                }
                              } finally {
                                setDialogState(() => isLoadingLocation = false);
                              }
                            },
                          )
                        : null,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newValue = controller.text.trim();
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(Auth().currentUser!.uid)
                          .update({fieldName: newValue});
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Manage Addresses"),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Shipping Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please make sure your details are correct before proceeding.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              if (Auth().currentUser != null)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(Auth().currentUser!.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Error loading data");
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    Map<String, dynamic> userData = {};
                    if (snapshot.hasData && snapshot.data!.exists) {
                      userData = snapshot.data!.data() as Map<String, dynamic>;
                    }
                    
                    final name = userData['name'] ?? "User";
                    final phone = userData['phone'] ?? "Add phone number";
                    final address = userData['address'] ?? "Add address";

                    return Column(
                      children: [
                        _buildInfoItem(
                          icon: Icons.person_outline,
                          title: "Nome",
                          value: name,
                          onTap: () => _showEditDialog(
                            context: context,
                            title: "Edit Name",
                            currentValue: name,
                            fieldName: "name",
                            hintText: "Enter your name",
                          ),
                        ),
                        _buildInfoItem(
                          icon: Icons.location_on_outlined,
                          title: "Indirizzo",
                          value: address,
                          onTap: () => _showEditDialog(
                            context: context,
                            title: "Edit Address",
                            currentValue: userData['address'] ?? "",
                            fieldName: "address",
                            hintText: "Enter your address",
                          ),
                        ),
                        _buildInfoItem(
                          icon: Icons.phone_outlined,
                          title: "Telefono",
                          value: phone,
                          onTap: () => _showEditDialog(
                            context: context,
                            title: "Edit Phone",
                            currentValue: userData['phone'] ?? "",
                            fieldName: "phone",
                            hintText: "Enter your phone number",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // 1. Fetch fresh user data for validation
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(Auth().currentUser!.uid)
                          .get();
                      
                      if (!userDoc.exists) throw Exception("User data not found");
                      
                      final userData = userDoc.data()!;
                      final String? address = userData['address'];
                      final String? phone = userData['phone'];

                      // 2. Validation
                      if (address == null || address.trim().isEmpty || 
                          phone == null || phone.trim().isEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please complete your address and phone number before confirming."),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                        return;
                      }

                      // 3. Stock Reduction (Atomic Batch)
                      final batch = FirebaseFirestore.instance.batch();
                      final cartItems = cartProvider.carts;
                      
                      debugPrint("Processing stock reduction for ${cartItems.length} items");
                      
                      for (var item in cartItems) {
                        final String? productId = item.grocery['id'];
                        final quantity = item.quantity;
                        
                        if (productId == null || productId.isEmpty) {
                          debugPrint("WARNING: Skipping stock reduction for item without ID: ${item.grocery['name']}");
                          continue;
                        }

                        debugPrint("Reducing stock for product: $productId by $quantity");
                        final productRef = FirebaseFirestore.instance.collection('product').doc(productId);
                        
                        // Use FieldValue.increment to ensure atomicity
                        batch.update(productRef, {
                          'stock': FieldValue.increment(-quantity),
                        });
                      }

                      await batch.commit();
                      debugPrint("Stock reduction batch committed successfully");

                      // 4. Finalize Order
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Your order has been processed, you will receive it as soon as possible."),
                            duration: Duration(seconds: 3),
                            backgroundColor: AppColors.primaryColor,
                          ),
                        );
                        // Clear cart
                        cartProvider.clearCart();
                        // Go back to Home
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Order failed: $e"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Confirm Order",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        trailing: const Icon(Icons.edit, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
