import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadDataToFirestore() async {
  final CollectionReference ref =
    FirebaseFirestore.instance.collection("myAppCollection");
  for (final ShopModel item in shops) {

    //generate a unique ID for each item
    final String id = DateTime.now().toIso8601String() + Random().nextInt(1000).toString();

    //assign the unique ID to the item
    final ShopModel itemWithId = ShopModel(
      id: id,
      image: item.image,
      name: item.name,
      price: item.price,
      shopId: item.shopId,
      description: item.description,
      category: item.category,
    );

    //upload the item to Firestore
    await ref.doc(id).set(itemWithId.toMap());
  }
}

final docRef = FirebaseFirestore.instance.collection('shops').doc();

class ShopModel {
  String id;
  String image;
  String name;
  double price;
  String shopId;
  String description;
  String category;
  ShopModel({
    required this.id,
    required this.image,
    required this.name,
    required this.price,
    required this.shopId,
    required this.description,
    required this.category,
  });

  //convert ShopModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'price': price,
      'shopId': shopId,
      'description': description,
      'category': category,
    };
  }
}

List<ShopModel> shops = [
  ShopModel(
    id: '',
    image:'',
    name:'',
    price:0.00,
    shopId:'',
    description:'',
    category:''
  )
];