class GithubHelper {
  static String convertUrl(String? url) {
    if (url == null || url.isEmpty) {
      return "https://via.placeholder.com/150";
    }
    
    // Se l'URL non inizia con http, presumiamo sia solo il nome del file
    if (!url.startsWith('http') && !url.startsWith('https')) {
      return 'https://raw.githubusercontent.com/Vlad-arch/EasyShopApp/main/easyshop/assets/images/$url';
    }
    
    return url;
  }
}
