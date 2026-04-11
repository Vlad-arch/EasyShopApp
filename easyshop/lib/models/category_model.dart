List<CategoryModel> categoriesFromJson(dynamic str) =>
  List<CategoryModel>.from((str).map((x) => CategoryModel.fromJson(x)));

class CategoryModel {
  int? categoryId;
  String? categoryName;
  ImageModel? image;

  CategoryModel({this.categoryId, this.categoryName, this.image});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    categoryId = json['id'];
    categoryName = json['name'].replaceAll("&amp;", "&");
    image = json['image'] != null ? ImageModel.fromJson(json['image']) : null;
  }
}

class ImageModel {
  String? url;

  ImageModel({
    this.url
  });

  ImageModel.fromJson(Map<String, dynamic> json) {
    url = json['src'];
  }
}