  // import 'package:flutter/material.dart';
  // import 'package:flutter/services.dart';
  // import 'package:flutter_svg/svg.dart';
  // import 'package:google_fonts/google_fonts.dart';

  // import '../model/productModel.dart';
  // import '../services/apiServices.dart';
  // import '../themes/light_color.dart';
  // import '../widgets/title_text.dart';

  // class CouponPage extends StatefulWidget {
  //   final Stores store;
  //   const CouponPage({required this.store});

  //   @override
  //   State<CouponPage> createState() => _CouponPageState();
  // }

  // class _CouponPageState extends State<CouponPage> {
  //   ScrollController? _scrollController;
  //   bool lastStatus = true;
  //   double height = 200;
  //   List<Coupon> coupons = [];

  //   void _scrollListener() {
  //     if (_isShrink != lastStatus) {
  //       setState(() {
  //         lastStatus = _isShrink;
  //       });
  //     }
  //   }

  //   bool get _isShrink {
  //     return _scrollController != null &&
  //         _scrollController!.hasClients &&
  //         _scrollController!.offset > (height - kToolbarHeight);
  //   }

  //   @override
  //   void initState() {
  //     super.initState();
  //     _scrollController = ScrollController()..addListener(_scrollListener);
  //     fetchStoreCoupons();
  //   }

  //   fetchStoreCoupons() async {
  //     List<Coupon> value =
  //         await ApiServices.fetchStoreCoupons(widget.store.storePageUrl!);
  //     setState(() {
  //       coupons = value; // Update coupons inside setState
  //     });
  //     print(coupons);
  //   }

  //   @override
  //   void dispose() {
  //     _scrollController?.removeListener(_scrollListener);
  //     _scrollController?.dispose();
  //     super.dispose();
  //   }

  //   @override
  //   Widget build(BuildContext context) {
  //     final TextTheme textTheme = Theme.of(context).textTheme;

  //     return MaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       theme: ThemeData.dark(),
  //       home: Scaffold(
  //         backgroundColor: Color.fromARGB(255, 37, 40, 47),
  //         body: NestedScrollView(
  //           controller: _scrollController,
  //           headerSliverBuilder: (context, innerBoxIsScrolled) {
  //             return [
  //               SliverAppBar(
  //                 elevation: 0,
  //                 toolbarHeight: 80,
  //                 backgroundColor: LightColor.background,
  //                 pinned: true,
  //                 expandedHeight: 200,
  //                 centerTitle: false,
  //                 automaticallyImplyLeading: false,
  //                 flexibleSpace: FlexibleSpaceBar(
  //                   titlePadding:
  //                       EdgeInsetsDirectional.only(start: 10, bottom: 16),
  //                   title: _isShrink
  //                       ? Padding(
  //                           padding: const EdgeInsets.only(top: 0.0),
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.start,
  //                             children: [
  //                               Container(
  //                                 width: 80,
  //                                 height: 40,
  //                                 padding: EdgeInsets.all(10),
  //                                 decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.circular(10),
  //                                   color: LightColor.titleTextColor
  //                                       .withOpacity(0.0),
  //                                   border: Border.all(
  //                                     color: LightColor.titleTextColor,
  //                                     width: 1,
  //                                   ),
  //                                 ),
  //                                 child: widget.store.imgUrl!.contains(".svg")
  //                                     ? SvgPicture.network(
  //                                         widget.store.imgUrl!,
  //                                       )
  //                                     : Image.network(widget.store.imgUrl!),
  //                               ),
  //                               SizedBox(width: 10),
  //                               TitleText(
  //                                 text: widget.store.storeName!,
  //                                 fontSize: 25,
  //                                 textAlign: TextAlign.start,
  //                                 color: const Color.fromARGB(255, 215, 217, 220),
  //                               ),
  //                             ],
  //                           ),
  //                         )
  //                       : null,
  //                   collapseMode: CollapseMode.parallax,
  //                   background: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Container(
  //                         width: 130,
  //                         height: 50,
  //                         padding: EdgeInsets.all(10),
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(10),
  //                           color: LightColor.titleTextColor.withOpacity(0.0),
  //                           border: Border.all(
  //                             color: LightColor.titleTextColor,
  //                             width: 2,
  //                           ),
  //                         ),
  //                         child: widget.store.imgUrl!.contains(".svg")
  //                             ? SvgPicture.network(
  //                                 widget.store.imgUrl!,
  //                               )
  //                             : Image.network(
  //                                 widget.store.imgUrl!,
  //                               ),
  //                       ),
  //                       const SizedBox(height: 16),
  //                       TitleText(
  //                         text: widget.store.storeName!,
  //                         fontSize: 25,
  //                         textAlign: TextAlign.start,
  //                         color: const Color.fromARGB(255, 215, 217, 220),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       Text(
  //                         "Grab your coupons right now !",
  //                         style: GoogleFonts.mulish(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.w500,
  //                           color: LightColor.titleTextColor,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 5),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ];
  //           },
  //           body: Padding(
  //             padding: const EdgeInsets.only(left: 8.0, right: 8, top: 20),
  //             child: CustomScrollView(
  //               physics: BouncingScrollPhysics(),
  //               slivers: [
  //                 SliverList.builder(
  //                   itemCount: coupons.length,
  //                   itemBuilder: (BuildContext context, int index) {
  //                     Coupon coupon = coupons[index];
  //                     return Padding(
  //                       padding: const EdgeInsets.only(
  //                         top: 20.0,
  //                         left: 10,
  //                         right: 10,
  //                       ),
  //                       child: Container(
  //                         padding: EdgeInsets.all(10),
  //                         width: double.infinity,
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(10),
  //                           color: LightColor.background,
  //                         ),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Row(
  //                               children: [
  //                                 Container(
  //                                     constraints: BoxConstraints(
  //                                         minWidth: 100, maxWidth: 100),
  //                                     padding: EdgeInsets.all(10),
  //                                     decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(10),
  //                                       color: Color.fromARGB(255, 37, 40, 47),
  //                                     ),
  //                                     child: Center(
  //                                       child: TitleText(
  //                                         text: coupon.veryShortTitle!,
  //                                         color: LightColor.subTitleTextColor,
  //                                         fontSize: 15,
  //                                       ),
  //                                     )),
  //                                 SizedBox(
  //                                   width: 10,
  //                                 ),
  //                                 Container(
  //                                   width:
  //                                       MediaQuery.of(context).size.width - 215,
  //                                   child: Text(coupon.couponTitle!,
  //                                       style: GoogleFonts.fredoka()),
  //                                 )
  //                               ],
  //                             ),
  //                             IconButton(
  //                               icon: Icon(Icons.copy_rounded,
  //                                   color: LightColor.titleTextColor
  //                                       .withOpacity(0.8)),
  //                               onPressed: () async {
  //                                 await Clipboard.setData(
  //                                     ClipboardData(text: coupon.couponCode!));
  //                               },
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }
