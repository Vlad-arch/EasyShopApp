class GithubHelper {
  static String convertUrl(String? url) {
    if (url == null || url.isEmpty) {
      return "https://via.placeholder.com/150";
    }

    url = url.trim();
    
    // Gestione URL: se è un link github.com (blob), lo convertiamo in raw.githubusercontent.com
    if (url.contains('github.com') && url.contains('/blob/')) {
      return url
          .replaceFirst('github.com', 'raw.githubusercontent.com')
          .replaceFirst('/blob/', '/');
    }

    // Se l'URL non inizia con http, presumiamo sia solo il nome del file
    if (!url.startsWith('http') && !url.startsWith('https')) {
      return 'https://raw.githubusercontent.com/Vlad-arch/EasyShopApp/main/easyshop/assets/images/$url';
    }
    
    return url;
  }
}
