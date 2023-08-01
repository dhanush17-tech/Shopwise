import 'package:shopwise/src/model/productModel.dart';

import 'category.dart';

class AppData {
  static List<Category> categoryList = [
    Category(
        id: 2,
        name: "Phone",
        image: 'assets/phone.png',
        dealType: "mobiles",
        isSelected: true),
    Category(
        id: 3,
        name: "Laptops",
        image: 'assets/laptop.png',
        dealType: "laptops",
        isSelected: false),
    Category(
        id: 4,
        name: "TVs",
        image: 'assets/tv1.png',
        dealType: "tv",
        isSelected: false),
  ];
  static List<String> showThumbnailList = [
    "assets/shoe_thumb_5.png",
    "assets/shoe_thumb_1.png",
    "assets/shoe_thumb_4.png",
    "assets/shoe_thumb_3.png",
  ];
  }
