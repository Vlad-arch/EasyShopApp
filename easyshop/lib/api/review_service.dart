import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:easyshop/config.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final String _baseUrl = Config.reviewsUrl;

  /// Fetches reviews for a given product ID.
  Future<Map<String, dynamic>> getReviews(String productId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/reviews/$productId'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("Failed to fetch reviews: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
        return {"reviews": [], "average_rating": 0.0, "total_reviews": 0};
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      return {"reviews": [], "average_rating": 0.0, "total_reviews": 0};
    }
  }

  /// Adds a new review for a product.
  Future<bool> addReview({
    required String productId,
    required String comment,
    required int rating,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'comment': comment,
          'rating': rating,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Error adding review: $e");
      return false;
    }
  }

  /// Updates an existing review.
  Future<bool> updateReview({
    required int reviewId,
    required String comment,
    required int rating,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      final token = await user.getIdToken();

      final response = await http.put(
        Uri.parse('$_baseUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'comment': comment,
          'rating': rating,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error updating review: $e");
      return false;
    }
  }

  /// Deletes a review.
  Future<bool> deleteReview(int reviewId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      final token = await user.getIdToken();

      final response = await http.delete(
        Uri.parse('$_baseUrl/reviews/$reviewId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error deleting review: $e");
      return false;
    }
  }
}
