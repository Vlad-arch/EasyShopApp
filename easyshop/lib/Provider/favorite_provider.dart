import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider with ChangeNotifier{
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> get favorites => _favoriteIds;
  FavoriteProvider() {
    loadFavorites();
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

  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection("productFavorite").doc(productId).set({
        'isFavorite': true,
        "productId":productId,
        });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection("productFavorite").doc(productId).delete();
    } catch (e) {
      print(e.toString());
    }
  }
  

  Future<void> loadFavorites() async {
    try {
      QuerySnapshot snapshot =
        await _firestore.collection("productFavorite").get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      _favoriteIds = [];
      print(e.toString());
    }
    notifyListeners();
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen);
  }
}