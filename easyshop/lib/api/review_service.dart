import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easyshop/config.dart';

class ReviewService {
  final String _baseUrl = Config.reviewsUrl;

  /// Fetches reviews for a given product ID.
  Future<List<Map<String, dynamic>>> getReviews(String productId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/reviews/$productId'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print("Failed to fetch reviews: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }

  /// Adds a new review for a product.
  Future<bool> addReview({
    required String productId,
    required String userName,
    required String comment,
    required int rating,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_id': productId,
          'user_name': userName,
          'comment': comment,
          'rating': rating,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error adding review: $e");
      return false;
    }
  }
}
