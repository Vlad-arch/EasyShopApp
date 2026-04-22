import 'dart:convert';
import 'dart:io';
import 'package:easyshop/config/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class GitStorageService {
  // Il token è ora gestito in lib/config/secrets.dart (ignorato da Git)
  static const String githubToken = AppSecrets.githubToken;
  static const String githubRepo = "Vlad-arch/EasyShopApp";
  static const String branch = "main";
  static const String basePath = "easyshop/assets/images";

  Future<String?> uploadImage(File imageFile) async {
    try {
      final String fileName =
          "${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}";
      final String uploadPath = "$basePath/$fileName";
      final String content = base64Encode(await imageFile.readAsBytes());

      final url = Uri.parse(
          "https://api.github.com/repos/$githubRepo/contents/$uploadPath");

      final response = await http.put(
        url,
        headers: {
          "Authorization": "token $githubToken",
          "Accept": "application/vnd.github.v3+json",
        },
        body: jsonEncode({
          "message": "Upload product image: $fileName",
          "content": content,
          "branch": branch,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Ritorna il nome del file da salvare in Firestore
        // Il GithubHelper si occuperà di convertirlo in URL raw
        return fileName;
      } else {
        print("Github upload failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error in uploadImage: $e");
      return null;
    }
  }
}
