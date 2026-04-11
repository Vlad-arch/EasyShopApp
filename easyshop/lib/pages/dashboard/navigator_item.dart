import 'package:flutter/material.dart';

class NavigatorItem {
  final String label, iconPath;
  final int index;
  final Widget screen;

  NavigatorItem(this.label, this.iconPath, this.index, this.screen);
}

List<NavigatorItem> navigatorItems = [
  NavigatorItem("Shop", "assets/icons/shop_icon.svg", 0, SizedBox()),
  NavigatorItem("Categories", "assets/icons/category_icon.svg", 0, SizedBox()),
  NavigatorItem("Cart", "assets/icons/cart_icon.svg", 0, SizedBox()),
  NavigatorItem("Account", "assets/icons/account_icon.svg", 0, SizedBox()),
];