class DriveHelper {
  static String convertUrl(String? url) {
    if (url == null || url.isEmpty) {
      return "https://via.placeholder.com/150";
    }
    
    if (url.contains('drive.google.com/file/d/')) {
      final RegExp regExp = RegExp(r'file/d/([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(url);
      if (match != null) {
        final id = match.group(1);
        return 'https://drive.google.com/uc?export=download&id=$id';
      }
    } else if (url.contains('drive.google.com/open?id=')) {
      final RegExp regExp = RegExp(r'id=([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(url);
      if (match != null) {
        final id = match.group(1);
        return 'https://drive.google.com/uc?export=download&id=$id';
      }
    }
    
    return url;
  }
}
