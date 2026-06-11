import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider with ChangeNotifier{
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> get favorites => _favoriteIds;
  FavoriteProvider() {
    // Listen for auth changes and reload favorites automatically
    FirebaseAuth.instance.authStateChanges().listen((user) {
      loadFavorites();
    });
  }

  void toggleFavorite(Map<String, dynamic> product)async{
    final productId = product['id'];
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await _removeFavorite(productId);
    }else{
      _favoriteIds.add(productId);
      await _addFavorite(productId);
    }
    notifyListeners();
  }

  bool isExist(Map<String, dynamic> product){
    final productId = product['id'];
    if (productId == null || productId is! String) {
      return false;
    }
    return _favoriteIds.contains(productId);
  }

  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _favoriteIds = [];
      notifyListeners();
      return;
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("favorites")
          .get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      _favoriteIds = [];
      debugPrint("Error loading favorites: $e");
    }
    notifyListeners();
  }

  Future<void> _addFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("favorites")
          .doc(productId)
          .set({
        'isFavorite': true,
        "productId": productId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error adding favorite: $e");
    }
  }

  Future<void> _removeFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("favorites")
          .doc(productId)
          .delete();
    } catch (e) {
      debugPrint("Error removing favorite: $e");
    }
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen);
  }
}