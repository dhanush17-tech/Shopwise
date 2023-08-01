import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../config/host.dart';
import '../model/productModel.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as htmlDom;

class ApiServices {
  static Future<List<Product>> itemSearch(searchTag) async {
    try {
      Dio dio = Dio();
      var response =
          await dio.get("${domain}/searchItem", data: {"itemName": searchTag});
      var body = response.data;

      List<Product> result =
          List<Product>.from(body.map((x) => Product.fromJson(x)));
      return result;
    } catch (e) {
      return [];
      print(e);
    }
  }

  static Future<List<String>> getSuggestions(String query) async {
    try {
      Dio dio = Dio();
      var response = await dio.get(
        "https://pricee.com/api/v1/suggest.php?q=$query&lang=en",
      );
      var body = response.data;
      List<List<dynamic>> data = List<List<dynamic>>.from(body["data"]);
      List<String> suggestions = data.map((item) => item[0] as String).toList();
      return suggestions;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<Product> getProductInfo(title, buyLink) async {
    try {
      final searchUrl =
          'https://www.amazon.in/s?k=${reduceToFirstFourWords(title.toLowerCase())}&crid=232C26IU722R5&sprefix=m%2Caps%2C295&ref=nb_sb_noss_2';
      final searchResponse = await http.get(Uri.parse(searchUrl), headers: {
        "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36",
        "Accept":
            "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "en-US,en;q=0.9",
      });

      final document = htmlParser.parse(searchResponse.body);
      final productElements =
          document.querySelectorAll(".s-result-item").sublist(1, 2);

      final shelf = productElements.isNotEmpty ? productElements[0] : null;
      if (shelf != null) {
        final images =
            shelf.querySelectorAll("img.s-image").map((imageElement) {
          return imageElement.attributes["src"] ?? "";
        }).toList();

        final totalReviewsElement = shelf.querySelector(
            "div.a-section.a-spacing-none.a-spacing-top-micro > div.a-row.a-size-small > span:last-child");
        final totalReviews =
            totalReviewsElement?.attributes["aria-label"] ?? "";

        final starsElement = shelf.querySelector(
            "div.a-section.a-spacing-none.a-spacing-top-micro > div > span");
        final stars = starsElement?.attributes["aria-label"] ?? "";

        final productTitleElement = shelf
            .querySelector("span.a-size-base-plus.a-color-base.a-text-normal");
        final productTitle = productTitleElement?.text ?? "";

        final descriptionElement = shelf.querySelector(
            ".a-section.a-spacing-none .a-size-base-plus.a-color-base");
        final description = descriptionElement?.text ?? "";

        String modifiedBuyLink =
            buyLink; // Store the original buyLink to prevent mutation
        if (buyLink.contains("pricebefore.com")) {
          final buyLinkResponse = await http.get(Uri.parse(buyLink));
          final p = htmlParser.parse(buyLinkResponse.body);
          modifiedBuyLink =
              p.querySelector(".buy-button a")?.attributes["href"] ?? "";
        }
        final linkElement = shelf
            .getElementsByClassName(
                "a-size-mini a-spacing-none a-color-base s-line-clamp-2")
            .first;
        final link = linkElement.firstChild?.attributes["href"];
        final amazonLink = link != null ? 'https://www.amazon.in$link' : "";

        final product = Product(
          images: images,
          buyLink: modifiedBuyLink,
          amazonLink: amazonLink,
          totalReviews: totalReviews,
          ratings: stars.replaceFirst("out of 5 stars", "").trim(),
          description: description,
          img: '',
          offer: '',
          price: '',
          title: '',
          websiteLogo: '',
        );

        return product;
      } else {
        String modifiedBuyLink = buyLink;
        if (buyLink.contains("pricebefore.com")) {
          final buyLinkResponse = await http.get(Uri.parse(buyLink));
          final p = htmlParser.parse(buyLinkResponse.body);
          modifiedBuyLink =
              p.querySelector(".buy-button a")?.attributes["href"] ?? "";
        }
        // No product found
        return Product(
          images: [],
          buyLink: modifiedBuyLink,
          amazonLink: "",
          totalReviews: "",
          ratings: "",
          description: '',
          img: '',
          offer: '',
          price: '',
          title: '',
          websiteLogo: '',
        );
      }
    } catch (e) {
      String modifiedBuyLink = buyLink;
      if (buyLink.contains("pricebefore.com")) {
        final buyLinkResponse = await http.get(Uri.parse(buyLink));
        final p = htmlParser.parse(buyLinkResponse.body);
        modifiedBuyLink =
            p.querySelector(".buy-button a")?.attributes["href"] ?? "";
      }
      // Handle error
      print("Error: $e");
      return Product(
        images: [],
        buyLink: modifiedBuyLink,
        amazonLink: "",
        totalReviews: "",
        ratings: "",
        description: '',
        img: '',
        offer: '',
        price: '',
        title: '',
        websiteLogo: '',
      );
    }
  }

  static Future<String?> getProductDescription(String amazonUrl) async {
    final searchResponse = await http.get(Uri.parse(amazonUrl), headers: {
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36",
      "Accept":
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "Accept-Encoding": "gzip, deflate, br",
      "Accept-Language": "en-US,en;q=0.9",
    });

    final document = htmlParser.parse(searchResponse.body);
    String? description = document.querySelector("#feature-bullets")?.text;
    return description?.trim().replaceAll("› See more product details", "");
  }

  static Future<List<Product>> barcodeSearch(
      code, Function(double) progressCallback) async {
    try {
      Dio dio = Dio();
      var response = await dio.get(
        "${domain}/barcodeScan",
        data: {"barcodeId": code},
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes != -1) {
            final progress = receivedBytes / totalBytes;
            progressCallback(progress);
          }
        },
      );
      var body = response.data;

      List<Product> result =
          List<Product>.from(response.data.map((x) => Product.fromJson(x)));

      return result;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static addCart(List? items, String? fcmTokenId,
      Function(double) progressCallback) async {
    try {
      Dio dio = Dio();
      var response = await dio.post(
        "${domain}/addCart",
        data: {"cartItems": items, "fcmTokenId": fcmTokenId},
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes != -1) {
            final progress = receivedBytes / totalBytes;
            progressCallback(progress);
          }
        },
      ).then((value) {
        if (value.statusCode == 200) {
          true;
        } else {
          return false;
        }
      });
    } catch (e) {
      return false;
    }
  }

  static Future<bool> unsubscribeFromTopic(token, title) async {
    try {
      Dio dio = Dio();
      var response = await dio.post("${domain}/unsubscribeFromTopic",
          data: {"token": token, "topic": title});
      var body = response.data;

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  static Future<List<Product>> getLatestDeals(
      String dealType, Function(double) progressCallback) async {
    try {
      const url = '$domain/latestDeals'; // Replace with your URL
      final dio = Dio();
      var response = await dio.get(
        url,
        data: {"dealType": dealType},
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes != -1) {
            final progress = receivedBytes / totalBytes;
            progressCallback(progress);
          }
        },
      );

      List<Product> result =
          List<Product>.from(response.data.map((x) => Product.fromJson(x)));
      print(result);
      return result;
    } catch (e) {
      return [];
      print(e);
    }
  }

  static Future<List<Coupon>> fetchLatestUsedCoupon() async {
    try {
      var response = await http.get(
        Uri.parse('https://flipshope.com/api/coupons/recentusedcoupons'),
      );

      if (response.statusCode == 200) {
        List<Coupon> coupons = List<Coupon>.from(
            jsonDecode(response.body)['data'].map((x) => Coupon.fromJson(x)));
        print(coupons);
        return coupons;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (err) {
      print("Error: $err");
      return [];
    }
  }

  static Future<Map<String, dynamic>> fetchBannersandSaleItems() async {
    final response = await http.get(Uri.parse(
        'https://flipshope.com/_next/data/wHnVSA0XP4h-mpmynkgrjj/home.json'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final items = responseData['pageProps'];

      List<Banners> banners = (items['bannersData']['data'] as List)
          .map((json) => Banners.fromJson(json))
          .toList();

      List<SalesItem> salesItems = (items['salesListData']['data'] as List)
          .map((json) => SalesItem.fromJson(json))
          .toList();
      return {"banners": banners, "salesItems": salesItems};
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  static Future<List<Stores>> fetchTrendingStores() async {
    const url = '$domain/getStores'; // Replace with your URL
    final dio = Dio();
    var response = await dio.get(
      url,
    );

    List<Stores> result =
        List<Stores>.from(response.data.map((x) => Stores.fromJson(x)));
    print(result);
    return result;
  }

  // static createPaymentIntent() async {
  //   try {
  //     Map<String, dynamic> body = {
  //       'amount': "1000",
  //       'currency': "INR",
  //     };

  //     var response = await http.post(
  //       Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //       headers: {
  //         'Authorization':
  //             'Bearer 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',
  //         'Content-Type': 'application/x-www-form-urlencoded'
  //       },
  //       body: body,
  //     );
  //     return json.decode(response.body);
  //   } catch (err) {
  //     StripeException.fromJson(jsonDecode(err.toString()));
  //   }
  // }
  static String? formatDescription(String? description) {
    if (description == null) {
      return null;
    }

    // Remove leading and trailing whitespaces
    description = description.trim();

    // Remove any extra newlines or tabs
    description = description.replaceAll('\n', ' ').replaceAll('\t', ' ');

    // Add ellipsis (...) at the end if the description is too long
    const maxLength = 200;
    if (description.length > maxLength) {
      description = description.substring(0, maxLength - 3) + '...';
    }

    return description;
  }

  static String reduceToFirstFourWords(String inputString) {
    List<String> words = inputString.split(' ');

    if (words.length >= 4) {
      // Join the first two words and return
      return '${words[0]} ${words[1]} ${words[2]} ${words[3]} ${words[4]}}';
    } else {
      // If the input string has fewer than two words, return the whole string
      return inputString;
    }
  }
}
