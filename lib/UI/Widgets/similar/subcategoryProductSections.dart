import 'package:e_commerce/Models/product.dart';
import 'package:e_commerce/Screens/AdvertisingBannerCarousel.dart';
import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/asdfg.dart';
import 'package:e_commerce/UI/Widgets/Atoms/wistlist_button.dart';
import 'package:e_commerce/UI/Widgets/similar/productDetailScreenSimple.dart';
import 'package:e_commerce/UI/Widgets/Atoms/card_product_list.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubcategoryProductSections extends StatelessWidget {
  const SubcategoryProductSections({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<Home>();

    if (home.isLoadingSubcategoryProducts) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (home.subcategoryProducts.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final subcategoryName =
              home.subcategoryProducts.keys.elementAt(index);
          final products = home.subcategoryProducts[subcategoryName]!;

          if (products.isEmpty) return const SizedBox.shrink();

          // Get names from first product for banner matching
          final subcategoryFromProduct = products.first.subcategory?.name ?? '';
          final categoryNameFromProduct = products.first.category?.name ?? '';

          return _SubcategorySection(
            title: subcategoryName,
            products: products,
            home: home,
            categoryId: products.first.category?.id ?? '',
            subcategoryFromProduct: subcategoryFromProduct,
            categoryNameFromProduct: categoryNameFromProduct,
          );
        },
        childCount: home.subcategoryProducts.length,
      ),
    );
  }
}

class _SubcategorySection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final Home home;
  final String categoryId;
  final String subcategoryFromProduct;
  final String categoryNameFromProduct;

  const _SubcategorySection({
    required this.title,
    required this.products,
    required this.home,
    required this.categoryId,
    required this.subcategoryFromProduct,
    required this.categoryNameFromProduct,
  });

  /// ✅ Dynamic: Returns the reference name that should match with banner
  String? _getBannerReferenceName() {
    // Priority 1: Subcategory name from product (e.g., "fruits", "vegetables")
    if (subcategoryFromProduct.isNotEmpty) {
      return subcategoryFromProduct;
    }
    
    // Priority 2: Category name from product
    if (categoryNameFromProduct.isNotEmpty) {
      return categoryNameFromProduct;
    }
    
    // Priority 3: Section title
    if (title.isNotEmpty) {
      return title;
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bannerReferenceName = _getBannerReferenceName();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bannerReferenceName != null)
          AdvertisingBannerCarousel(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filterByReferenceName: bannerReferenceName, 
            filterByBannerTypes: const ['category-page', 'home-category'],
          ),
        
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubCategoryScreen(
                        categoryId: categoryId,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // PRODUCTS HORIZONTAL SCROLL
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              products.length,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _HorizontalProductCard(
                  product: products[i],
                  home: home,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// _HorizontalProductCard class remains exactly the same as before
class _HorizontalProductCard extends StatelessWidget {
  final Product product;
  final Home home;

  const _HorizontalProductCard({
    required this.product,
    required this.home,
  });

  bool _isValidImage(String? url) {
    return url != null && url.trim().isNotEmpty && url.startsWith('http');
  }

  double getDisplayPrice() {
    final quantity = home.getQuantity(product.id);
    if (quantity > 0) {
      final range = product.getDiscountRangeForQuantity(quantity);
      if (range != null && range.price > 0) return range.price;
    }
    return product.salePrice;
  }

  @override
  Widget build(BuildContext context) {
    final quantity = home.getQuantity(product.id);

    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, _) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreenSimple(
                  productId: product.id,
                ),
              ),
            );
          },
          child: Container(
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(7),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _isValidImage(product.imagePath)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  product.imagePath,
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => _placeholder(),
                                ),
                              )
                            : _placeholder(),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: WishlistButton(
                          productId: product.id,
                          productType: product.source,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.weight != null
                                  ? '${product.weight!.value} ${product.weight!.unit}'
                                  : '',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          quantity == 0
                              ? GestureDetector(
                                  onTap: () {
                                    home.incrementQuantity(product.id);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF003D73),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF003D73),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          home.decrementQuantity(product.id);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          home.incrementQuantity(product.id);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '₹${getDisplayPrice().toInt()}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 2),
                          if (product.mrp > product.salePrice)
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              runSpacing: 2,
                              children: [
                                Text(
                                  '₹${product.mrp.toInt()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.lineThrough,
                                    decorationThickness: 2,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => showBulkDiscountPopup(
                          context,
                          product.bulkPricing,
                          product,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'See Bulk Price',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 28,
        color: Colors.grey.shade200,
      ),
    );
  }
}

// import 'package:e_commerce/Models/product.dart';
// import 'package:e_commerce/Screens/AdvertisingBannerCarousel.dart';
// import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:e_commerce/UI/Widgets/Atoms/asdfg.dart';
// import 'package:e_commerce/UI/Widgets/Atoms/wistlist_button.dart';
// import 'package:e_commerce/UI/Widgets/similar/productDetailScreenSimple.dart';
// import 'package:e_commerce/UI/Widgets/Atoms/card_product_list.dart';
// import 'package:e_commerce/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SubcategoryProductSections extends StatelessWidget {
//   const SubcategoryProductSections({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final home = context.watch<Home>();

//     if (home.isLoadingSubcategoryProducts) {
//       return const SliverToBoxAdapter(
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 24),
//           child: Center(child: CircularProgressIndicator()),
//         ),
//       );
//     }

//     if (home.subcategoryProducts.isEmpty) {
//       return const SliverToBoxAdapter(child: SizedBox.shrink());
//     }

//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (context, index) {
//           final subcategoryName =
//               home.subcategoryProducts.keys.elementAt(index);
//           final products = home.subcategoryProducts[subcategoryName]!;

//           if (products.isEmpty) return const SizedBox.shrink();

//           return _SubcategorySection(
//             title: subcategoryName,
//             products: products,
//             home: home,
//             categoryId: products.first.category?.id ?? '',
//           );
//         },
//         childCount: home.subcategoryProducts.length,
//       ),
//     );
//   }
// }

// class _SubcategorySection extends StatelessWidget {
//   final String title;
//   final List<Product> products;
//   final Home home;
//   final String categoryId;

//   const _SubcategorySection({
//     required this.title,
//     required this.products,
//     required this.home,
//     required this.categoryId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//      AdvertisingBannerCarousel(
//   height: 100,
//   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//   filterByReferenceName: categoryId,
//   filterByBannerTypes: const ['category-page', 'home-category'],
// ),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//           child: Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 16,
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryOrangeColor,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w900,
//                     color: Color(0xFF1A1A2E),
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => SubCategoryScreen(
//                         categoryId: categoryId,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Row(
//                   children: const [
//                     Text(
//                       'See All',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black,
//                       ),
//                     ),
//                     SizedBox(width: 2),
//                     Icon(
//                       Icons.arrow_forward_ios,
//                       size: 12,
//                       color: Colors.black,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // ✅ PRODUCTS HORIZONTAL SCROLL
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: List.generate(
//               products.length,
//               (i) => Padding(
//                 padding: const EdgeInsets.only(right: 12),
//                 child: _HorizontalProductCard(
//                   product: products[i],
//                   home: home,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }
// }

// class _HorizontalProductCard extends StatelessWidget {
//   final Product product;
//   final Home home;

//   const _HorizontalProductCard({
//     required this.product,
//     required this.home,
//   });

//   bool _isValidImage(String? url) {
//     return url != null && url.trim().isNotEmpty && url.startsWith('http');
//   }

//   double getDisplayPrice() {
//     final quantity = home.getQuantity(product.id);
//     if (quantity > 0) {
//       final range = product.getDiscountRangeForQuantity(quantity);
//       if (range != null && range.price > 0) return range.price;
//     }
//     return product.salePrice;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final quantity = home.getQuantity(product.id);

//     return Consumer<WishlistProvider>(
//       builder: (context, wishlistProvider, _) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ProductDetailScreenSimple(
//                   productId: product.id,
//                 ),
//               ),
//             );
//           },
//           child: Container(
//             width: 150,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: Colors.grey.shade100),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.04),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: 120,
//                   child: Stack(
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         margin: const EdgeInsets.all(7),
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.06),
//                               blurRadius: 5,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: _isValidImage(product.imagePath)
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Image.network(
//                                   product.imagePath,
//                                   width: double.infinity,
//                                   height: 100,
//                                   fit: BoxFit.contain,
//                                   errorBuilder: (_, __, ___) => _placeholder(),
//                                 ),
//                               )
//                             : _placeholder(),
//                       ),
//                       Positioned(
//                         top: 12,
//                         right: 12,
//                         child: WishlistButton(
//                           productId: product.id,
//                           productType: product.source,
//                           size: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         product.name,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 11.5,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF1A1A2E),
//                           height: 1.25,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               product.weight != null
//                                   ? '${product.weight!.value} ${product.weight!.unit}'
//                                   : '',
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey.shade500,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           quantity == 0
//                               ? GestureDetector(
//                                   onTap: () {
//                                     home.incrementQuantity(product.id);
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 8,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFF003D73),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: const Text(
//                                       'Add',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w800,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : Container(
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF003D73),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       InkWell(
//                                         onTap: () {
//                                           home.decrementQuantity(product.id);
//                                         },
//                                         child: const Padding(
//                                           padding: EdgeInsets.symmetric(
//                                             horizontal: 10,
//                                             vertical: 8,
//                                           ),
//                                           child: Icon(
//                                             Icons.remove,
//                                             color: Colors.white,
//                                             size: 18,
//                                           ),
//                                         ),
//                                       ),
//                                       Text(
//                                         '$quantity',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           home.incrementQuantity(product.id);
//                                         },
//                                         child: const Padding(
//                                           padding: EdgeInsets.symmetric(
//                                             horizontal: 10,
//                                             vertical: 8,
//                                           ),
//                                           child: Icon(
//                                             Icons.add,
//                                             color: Colors.white,
//                                             size: 18,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                         ],
//                       ),
//                       const SizedBox(height: 2),
//                       Row(
//                         children: [
//                           Text(
//                             '₹${getDisplayPrice().toInt()}',
//                             style: const TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w900,
//                               color: Colors.black,
//                             ),
//                           ),
//                           const SizedBox(width: 2),
//                           if (product.mrp > product.salePrice)
//                             Wrap(
//                               crossAxisAlignment: WrapCrossAlignment.center,
//                               spacing: 4,
//                               runSpacing: 2,
//                               children: [
//                                 Text(
//                                   '₹${product.mrp.toInt()}',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey.shade500,
//                                     decoration: TextDecoration.lineThrough,
//                                     decorationThickness: 2,
//                                   ),
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 4,
//                                     vertical: 1,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.shade50,
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: Text(
//                                     '${product.discountPercentage.toStringAsFixed(0)}% OFF',
//                                     style: TextStyle(
//                                       fontSize: 8,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.green.shade700,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                       SizedBox(height: 5),
//                       GestureDetector(
//                         onTap: () => showBulkDiscountPopup(
//                           context,
//                           product.bulkPricing,
//                           product,
//                         ),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 3,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.green.shade50,
//                             borderRadius: BorderRadius.circular(5),
//                             border: Border.all(
//                               color: Colors.green.withOpacity(0.15),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 'See Bulk Price',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green.shade700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _placeholder() {
//     return Center(
//       child: Icon(
//         Icons.image_outlined,
//         size: 28,
//         color: Colors.grey.shade200,
//       ),
//     );
//   }
// }
