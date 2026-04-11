import 'package:easyshop/Provider/Model/cart_model.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<CartModel> _carts = [];
  List<CartModel> get carts => _carts;
  set carts(List<CartModel> carts) {
    _carts = carts;
    notifyListeners();
  }

//add product to the cart
  void addCart(Map<String, dynamic> grocery) { 
    if (productExist(grocery)) {
      int index = _carts
        .indexWhere((element) => element.grocery['id'] == grocery['id']);
      _carts[index].quantity = _carts[index].quantity + 1;  
    }else{
      _carts.add(CartModel(grocery: grocery, quantity: 1));
    }
    notifyListeners();
  } 
  //increase the quantity of product in the cart
  void addQuantity(Map<String, dynamic> grocery){
    int index = _carts
        .indexWhere((element) => element.grocery['id'] == grocery['id']);
    if(index != -1){
      //ensure the product exists
      _carts[index].quantity = _carts[index].quantity + 1;
    }
  }
  //decrease the quantity of product in the cart
  void reduceQuantity(Map<String, dynamic> grocery){
    int index = _carts
        .indexWhere((element) => element.grocery['id'] == grocery['id']);
    if(index != -1){
      //ensure the quantity is greater than 1
      _carts[index].quantity = _carts[index].quantity - 1;
      notifyListeners();
    }else if (index != -1 && _carts[index].quantity == 1){
      
    }
  }
  //checks if a product already exist in the cart
  bool productExist(Map<String, dynamic> grocery){
    return _carts
      .indexWhere((element) => element.grocery['id'] == grocery['id']) != -1;
  }

  //removes a producr from the cart
  void removeFromCart(Map<String, dynamic> grocery){
    int index = _carts
        .indexWhere((element) => element.grocery['id'] == grocery['id']);
    if (index != -1){
      _carts.removeAt(index);
      notifyListeners();
    }    
  }
  //calculate total price of cart
  double totalCart(){
    double total = 0;
    for(var i = 0; i < _carts.length; i++) {
      total += _carts[i].quantity * double.parse(_carts[i].grocery['price'].toString());
    } 
    return total;
  }
}