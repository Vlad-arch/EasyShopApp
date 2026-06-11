import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyshop/Provider/cart_provider.dart';
import 'package:easyshop/Views/cart_screen.dart';
import 'package:easyshop/Provider/favorite_provider.dart';
import 'package:easyshop/Widgets/cart_icon.dart';
import 'package:easyshop/Widgets/unit_conversion.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:easyshop/utils/github_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easyshop/api/review_service.dart';
import 'package:easyshop/auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easyshop/Views/app_main_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> grocery;
  const ItemDetailsScreen({super.key, required this.grocery});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  double? _averageRating;
  int _totalReviews = 0;
  String? _shopName;

  @override
  void initState() {
    super.initState();
    _averageRating = (widget.grocery['rating'] ?? 0.0).toDouble();
    _fetchShopName();
  }

  Future<void> _fetchShopName() async {
    final shopId = widget.grocery['shop'];
    if (shopId == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
      if (doc.exists) {
        if (mounted) {
          setState(() {
            _shopName = doc.data()?['name'] ?? shopId;
          });
        }
      } else {
        if (mounted) setState(() => _shopName = shopId);
      }
    } catch (e) {
      if (mounted) setState(() => _shopName = shopId);
    }
  }

  void _updateRating(double avg, int count) {
    if (mounted) {
      setState(() {
        _averageRating = avg;
        _totalReviews = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = Provider.of<CartProvider>(context);
    final grocery = widget.grocery;
    final int stock = grocery['stock'] ?? 0;
    final bool isOutOfStock = stock <= 0;
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
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
                  _averageRating?.toStringAsFixed(1) ?? "0.0",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_totalReviews > 0)
                  Text(
                    " ($_totalReviews)",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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
              if (_shopName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.store, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        _shopName!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isOutOfStock)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "Temporarily Out of Stock",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
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
                        onTap: isOutOfStock ? null : () {
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
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            color: isOutOfStock ? Colors.grey : AppColors.primaryColor,
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
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          color: isOutOfStock ? Colors.grey : AppColors.primaryColor,
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
              const Divider(height: 40, thickness: 1),
              ReviewsWidget(
                productId: grocery['id'] ?? "unknown",
                onRatingChanged: _updateRating,
              ),
              const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Highlight Home as default
        selectedItemColor: AppColors.primaryColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedItemColor: Colors.black45,
        elevation: 0,
        backgroundColor: AppColors.secondaryColor,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AppMainScreen(initialIndex: value),
            ),
            (route) => false,
          );
        },
        items: const [
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
    );
  }
}

class ReviewsWidget extends StatefulWidget {
  final String productId;
  final Function(double, int)? onRatingChanged;
  const ReviewsWidget({super.key, required this.productId, this.onRatingChanged});

  @override
  State<ReviewsWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends State<ReviewsWidget> {
  final _commentController = TextEditingController();
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;
  bool hasUserReviewed = false;
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final currentUserId = Auth().currentUser?.uid;
    final response = await ReviewService().getReviews(widget.productId);
    
    final List<Map<String, dynamic>> data = (response['reviews'] as List).cast<Map<String, dynamic>>();
    final double avg = (response['average_rating'] ?? 0.0).toDouble();
    final int count = (response['total_reviews'] ?? 0).toInt();

    bool userReviewed = false;
    if (currentUserId != null) {
      userReviewed = data.any((review) => review['user_id'] == currentUserId);
    }

    if (mounted) {
      setState(() {
        reviews = data;
        hasUserReviewed = userReviewed;
        isLoading = false;
      });
      if (widget.onRatingChanged != null) {
        widget.onRatingChanged!(avg, count);
      }
    }
  }

  Future<void> _postReview() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = Auth().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to leave a review")),
      );
      return;
    }

    final success = await ReviewService().addReview(
      productId: widget.productId,
      comment: _commentController.text.trim(),
      rating: _selectedRating,
    );

    if (success) {
      _commentController.clear();
      setState(() => _selectedRating = 5);
      _loadReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review added!")),
        );
      }
    }
  }

  Future<void> _editReview(int reviewId, String currentComment, int currentRating) async {
    final TextEditingController editController = TextEditingController(text: currentComment);
    int newRating = currentRating;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Review"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: const InputDecoration(hintText: "Your comment..."),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Rating: "),
                  DropdownButton<int>(
                    value: newRating,
                    items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                    onChanged: (val) => setDialogState(() => newRating = val!),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final success = await ReviewService().updateReview(
                  reviewId: reviewId,
                  comment: editController.text.trim(),
                  rating: newRating,
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                  _loadReviews();
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReview(int reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review"),
        content: const Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ReviewService().deleteReview(reviewId);
      if (success) {
        _loadReviews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review deleted")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Auth().currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer Reviews",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (reviews.isEmpty)
            const Text("No reviews yet. Be the first to review!")
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final reviewMap = reviews[index];
                // Using dynamic cast to handle different types if needed
                final int reviewId = reviewMap['id'] is int ? reviewMap['id'] : int.parse(reviewMap['id'].toString());
                final String userId = reviewMap['user_id'] ?? '';
                final String userName = reviewMap['user_name'] ?? 'Anonymous';
                final String comment = reviewMap['comment'] ?? '';
                final int rating = reviewMap['rating'] is int ? reviewMap['rating'] : int.parse(reviewMap['rating'].toString());

                final isOwner = currentUserId == userId;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(
                              Icons.star, 
                              color: i < rating ? Colors.amber : Colors.grey[300], 
                              size: 16
                            )),
                            if (isOwner) ...[
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                onPressed: () => _editReview(reviewId, comment, rating),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                onPressed: () => _deleteReview(reviewId),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(comment),
                    Text(
                      reviewMap['created_at']?.split(' ')[0] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 20),
          if (currentUserId != null && !hasUserReviewed) ...[
            const Text("Add a review", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              children: List.generate(5, (index) => GestureDetector(
                onTap: () => setState(() => _selectedRating = index + 1),
                child: Icon(
                  Icons.star,
                  color: index < _selectedRating ? Colors.amber : Colors.grey[300],
                  size: 28,
                ),
              )),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: "Write your comment..."),
                  ),
                ),
                IconButton(
                  onPressed: _postReview,
                  icon: const Icon(Icons.send, color: AppColors.primaryColor),
                ),
              ],
            ),
          ] else if (currentUserId != null && hasUserReviewed)
            const Text("You have already reviewed this product. You can edit or delete your review above.", 
                       style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic, fontSize: 13))
          else
            const Text("Log in to add a review", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}