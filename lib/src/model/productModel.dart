import 'dart:convert';

class Coupon {
  String? couponCode;
  String? couponTitle;
  String? veryShortTitle;
  String? imgUrl;

  Coupon({this.couponCode, this.couponTitle, this.veryShortTitle});

  Coupon.fromJson(Map<String, dynamic> json) {
    couponCode = json['Coupon_Code'];
    couponTitle = json['Coupon_Title'];
    veryShortTitle = json['Very_Short_Title'];
    imgUrl = json["img_url"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['coupon_Code'] = this.couponCode;
    data['coupon_Title'] = this.couponTitle;
    data['very_Short_Title'] = this.veryShortTitle;
    data["img_url"];
    this.imgUrl;
    return data;
  }
}

class Stores {
  String? imgUrl;
  String? storeUrl;
  String? storeId;
  String? storePageUrl;
  String? storeName;

  Stores(
      {this.imgUrl,
      this.storeUrl,
      this.storeId,
      this.storePageUrl,
      this.storeName});

  Stores.fromJson(Map<String, dynamic> json) {
    imgUrl = json['img_url'];
    storeUrl = json['store_url'];
    storeId = json['store_id'];
    storePageUrl = json['store_page_url'];
    storeName = json['store_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['img_url'] = this.imgUrl;
    data['store_url'] = this.storeUrl;
    data['store_id'] = this.storeId;
    data['store_page_url'] = this.storePageUrl;
    data['store_name'] = this.storeName;
    return data;
  }
}

class Banners {
  final String img_url;
  final String url;

  Banners({required this.img_url, required this.url});

  factory Banners.fromJson(Map<String, dynamic> json) {
    return Banners(
      img_url: json['img_url'],
      url: json['url'],
    );
  }
}

class SalesItem {
  final String img_url;
  final String url;
  final String title;

  SalesItem({required this.img_url, required this.url, required this.title});

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      img_url: json['img_url'],
      url: json['url'],
      title: json['title'],
    );
  }
}

class Product {
  String price;
  String title;
  String offer;
  String img;
  String buyLink;
  String websiteLogo;
  String ratings;
  String totalReviews;
  List images;
  String description;
  String amazonLink;
  Product(
      {required this.price,
      required this.title,
      required this.offer,
      required this.img,
      required this.buyLink,
      required this.description,
      required this.images,
      required this.amazonLink,
      required this.ratings,
      required this.totalReviews,
      required this.websiteLogo});

  static String praseHTMLToText(String praseHTMLContent) {
    String data = '';
    if (praseHTMLContent.isNotEmpty) {
      data = praseHTMLContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    }
    return data;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json["images"] != null) {
      images = List<String>.from(json["images"]);
    }

    return Product(
        price: json["price"] ?? "",
        title: json["title"] != null ? praseHTMLToText(json["title"]) : "",
        offer: json["offer"] ?? "",
        images: images,
        ratings: json["ratings"] ?? "",
        totalReviews: "",
        amazonLink: json["amazonLink"] ?? "",
        img: json["img"] != null ? json["img"] : "",
        buyLink: json["buyLink"] != null ? json["buyLink"] : "",
        websiteLogo: json["websiteLogo"] != null
            ? json["websiteLogo"]
            : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRT6FUE6ulwBRmatVbvGulbnn6nVXd6DQHaeQ&usqp=CAU",
        description: json["description"] != null ? json["description"] : "");
  }

  Map<String, dynamic> toJson() => {
        "price": price,
        "title": title,
        "offer": offer,
        "ratings": ratings,
        "img": img,
        "buyLink": buyLink,
        "websiteLogo": websiteLogo,
        "description": description,
        "images": images,
        "amazonLink": amazonLink
      };
  static List<Product> parseList(String jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
    return parsed.map<Product>((json) => Product.fromJson(json)).toList();
  }

  static String stringifyList(List<Product> products) {
    final List<Map<String, dynamic>> productList =
        products.map((product) => product.toJson()).toList();
    return json.encode(productList);
  }
}
