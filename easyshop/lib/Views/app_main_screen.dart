import 'package:easyshop/Views/cart_screen.dart';
import 'package:easyshop/Views/favorite_screen.dart';
import 'package:easyshop/Views/home_page.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/utils/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

class AppMainScreen extends StatefulWidget {
  final int initialIndex;
  const AppMainScreen({super.key, this.initialIndex = 0});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }
  final List pages = [
    const HomePage(),
    const FavoriteScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  String _getPageTitle(int index) {
    switch (index) {
      case 1:
        return "Favorite";
      case 2:
        return "Cart";
      case 3:
        return "Profile";
      default:
        return "";
    }
  }

  Widget _getPageIcon(int index) {
    switch (index) {
      case 1:
        return const Icon(Icons.favorite, color: Colors.red, size: 28);
      case 2:
        return const Icon(Icons.shopping_cart, color: AppColors.primaryColor, size: 28);
      case 3:
        return const Icon(Icons.person, color: Colors.grey, size: 28);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 140,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/logo_app.png',
              height: 120,
            ),
            if (selectedIndex != 0) ...[
              const Spacer(),
              Text(
                _getPageTitle(selectedIndex),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _getPageIcon(selectedIndex),
              const SizedBox(width: 15),
            ],
          ],
        ),
        centerTitle: false,
      ),
      bottomNavigationBar:BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedItemColor: Colors.black45,
        elevation: 0,
        backgroundColor: AppColors.secondaryColor,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        } ,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            activeIcon: Icon(Iconsax.home5),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.heart),
            activeIcon: Icon(Iconsax.heart5),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.shopping_cart),
            activeIcon: Icon(Iconsax.shopping_cart5),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person_outlined),
            label: "Profile",
          ),    
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                      final user = Auth().currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({fieldName: newValue}, SetOptions(merge: true));
                        
                        if (fieldName == 'name') {
                          await user.updateDisplayName(newValue);
                        }
                      }
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

  Future<void> _showPasswordDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    bool isLoading = false;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Change Password"),
              content: TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Enter new password",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    final newPassword = controller.text.trim();
                    if (newPassword.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password must be at least 6 characters")),
                      );
                      return;
                    }
                    setDialogState(() => isLoading = true);
                    try {
                      await Auth().changePassword(newPassword);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Password updated successfully!")),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    } finally {
                      setDialogState(() => isLoading = false);
                    }
                  },
                  child: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Update"),
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  final user = Auth().currentUser;
                  if (user != null) {
                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
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
                        final email = user.email ?? "";

                        return Column(
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              email,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 30),
                            _buildProfileItem(
                              icon: Icons.person_outline,
                              title: "Name",
                              value: name,
                              onTap: () => _showEditDialog(
                                context: context,
                                title: "Edit Name",
                                currentValue: name,
                                fieldName: "name",
                                hintText: "Enter your name",
                              ),
                            ),
                            _buildProfileItem(
                              icon: Icons.phone_outlined,
                              title: "Phone",
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
                            _buildProfileItem(
                              icon: Icons.location_on_outlined,
                              title: "Address",
                              value: address,
                              onTap: () => _showEditDialog(
                                context: context,
                                title: "Edit Address",
                                currentValue: userData['address'] ?? "",
                                fieldName: "address",
                                hintText: "Enter your address",
                              ),
                            ),
                            _buildProfileItem(
                              icon: Icons.lock_outline,
                              title: "Security",
                              value: "Change Password",
                              onTap: () => _showPasswordDialog(context),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return const Text("No user logged in", style: TextStyle(fontSize: 18));
                  }
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Auth().signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Sign Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
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
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}