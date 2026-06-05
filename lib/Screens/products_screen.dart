import 'package:e_commerce/Models/public_model.dart';
import 'package:e_commerce/Models/product.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/similar/productDetailScreenSimple.dart';
import 'package:e_commerce/UI/Widgets/Organisms/bottom_cart_container.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryProductScreen extends StatefulWidget {
  final AppCategory category;

  const CategoryProductScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  int _selectedSubIndex = 0;
  int _selectedSubSubIndex = 0; // 0 = "All"

  AppSubCategory get _selectedSub =>
      widget.category.subcategories[_selectedSubIndex];

  List<Product> get _visibleProducts {
    final sub = _selectedSub;

    if (sub.subSubCategories.isNotEmpty) {
      if (_selectedSubSubIndex == 0) {
        // "All" — subcategory ke saare products
        final all = <Product>[];
        all.addAll(sub.products);
        for (final ss in sub.subSubCategories) {
          all.addAll(ss.products);
        }
        return all;
      }
      return sub.subSubCategories[_selectedSubSubIndex - 1].products;
    }

    return sub.products;
  }

  bool _isValidImage(String? url) =>
      url != null && url.trim().isNotEmpty && url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final subs = widget.category.subcategories;

    if (subs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.category.name),
          backgroundColor: Colors.orange,
        ),
        body: const Center(child: Text('No subcategories')),
      );
    }

    return Consumer<Home>(
      builder: (context, home, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.category.name),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          body: Row(
            children: [
              Container(
                width: 80,
                color: Colors.grey.shade100,
                child: ListView.builder(
                  itemCount: subs.length,
                  itemBuilder: (context, index) {
                    final sub = subs[index];
                    final isSelected = index == _selectedSubIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSubIndex = index;
                          _selectedSubSubIndex = 0;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.transparent,
                          border: Border(
                            right: BorderSide(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            if (sub.image.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  sub.image,
                                  height: 40,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.category,
                                    size: 30,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.category,
                                size: 30,
                                color: Colors.grey.shade400,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              sub.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    if (_selectedSub.subSubCategories.isNotEmpty)
                      _buildSubSubChips(),

                    Expanded(
                      child: _visibleProducts.isEmpty
                          ? const Center(
                              child: Text(
                                'No products available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(10),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.62,
                              ),
                              itemCount: _visibleProducts.length,
                              itemBuilder: (context, index) {
                                final product = _visibleProducts[index];
                                final quantity =
                                    home.getQuantity(product.id);

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetailScreenSimple(
                                          productId: product.id,
                                        ),
                                      ),
                                    );
                                  },
                         
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 3,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // IMAGE + ADD BUTTON
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                              child: _isValidImage(
                                                      product.imagePath)
                                                  ? Image.network(
                                                      product.imagePath,
                                                      height: 110,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __,
                                                              ___) =>
                                                          _imgPlaceholder(),
                                                    )
                                                  : _imgPlaceholder(),
                                            ),

                                            // ADD / QUANTITY BUTTON
                                            Positioned(
                                              bottom: 8,
                                              right: 8,
                                              child: quantity == 0
                                                  ? InkWell(
                                                      onTap: () => home
                                                          .incrementQuantity(
                                                              product.id),
                                                      child: Container(
                                                        height: 30,
                                                        width: 40,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                            color: AppColors
                                                                .primaryOrangeColor,
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.add,
                                                          size: 16,
                                                          color: AppColors
                                                              .primaryOrangeColor,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      height: 30,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .primaryOrangeColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          InkWell(
                                                            onTap: () => home
                                                                .decrementQuantity(
                                                                    product.id),
                                                            child: const Icon(
                                                              Icons.remove,
                                                              size: 14,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6),
                                                            child: Text(
                                                              '$quantity',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () => home
                                                                .incrementQuantity(
                                                                    product.id),
                                                            child: const Icon(
                                                              Icons.add,
                                                              size: 14,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        ),

                                        // DETAILS
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Price
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade700,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '₹${product.salePrice}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              // Name
                                              Text(
                                                product.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.3,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              // Weight
                                              if (product.weight != null)
                                                Text(
                                                  '${product.weight!.value}${product.weight!.unit}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        Colors.grey.shade600,
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
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Consumer<Home>(
            builder: (context, provider, _) {
              return provider.hasItems
                  ? const BottomStickyContainer()
                  : const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildSubSubChips() {
    final subSubs = _selectedSub.subSubCategories;
    return Container(
      height: 44,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: subSubs.length + 1, // +1 for "All"
        itemBuilder: (_, i) {
          final isSelected = i == _selectedSubSubIndex;
          final label = i == 0 ? 'All' : subSubs[i - 1].name;
          return GestureDetector(
            onTap: () => setState(() => _selectedSubSubIndex = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.orange
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.orange
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        height: 110,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: Icon(Icons.image, size: 40, color: Colors.grey.shade400),
      );
}

// import 'package:e_commerce/Models/category_model.dart';
// import 'package:e_commerce/Screens/product_detail_screen.dart';
// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:e_commerce/UI/Widgets/Organisms/bottom_cart_container.dart';
// import 'package:e_commerce/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class CategoryProductScreen extends StatefulWidget {
//   final Category category;

//   const CategoryProductScreen({
//     super.key,
//     required this.category,
//   });

//   @override
//   State<CategoryProductScreen> createState() => _CategoryProductScreenState();
// }

// class _CategoryProductScreenState extends State<CategoryProductScreen> {
//   int selectedIndex = 0;

//   bool isValidImage(String? url) {
//     return url != null && url.trim().isNotEmpty && url.startsWith('http');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<Home>(builder: (context, home, _) {
//       //  final product = home.selectedProduct;

//       if (home.isLoadingProducts) {
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       }

//       // if (product == null) {
//       //   return const Scaffold(
//       //     body: Center(child: Text('Product not found')),
//       //   );
//       // }

//       //  final quantity = home.getQuantity(product.id);

//       final subCategories = widget.category.subcategories ?? [];

//       if (subCategories.isEmpty) {
//         return Scaffold(
//           appBar: AppBar(title: Text(widget.category.name)),
//           body: const Center(child: Text('No subcategories')),
//         );
//       }

//       final selectedSubCategory = subCategories[selectedIndex];
//       final products = selectedSubCategory.products ?? [];
//       // final hasItems = context.select<ProductProvider, bool>(
//       //           (p) => p.hasItems,);
//       // debugPrint("hasItems = $hasItems");
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(widget.category.name),
//           backgroundColor: Colors.orange,
//         ),
//         body: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 80,
//               child: ListView.builder(
//                 itemCount: subCategories.length,
//                 itemBuilder: (context, index) {
//                   final sub = subCategories[index];
//                   final isSelected = index == selectedIndex;

//                   return GestureDetector(
//                     onTap: () {
//                       setState(() => selectedIndex = index);
//                       // context.read<Home>()
//                       // .fetchProductsBySubCategory(sub.id!);
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         border: Border(
//                           right: BorderSide(
//                             color:
//                                 isSelected ? Colors.orange : Colors.transparent,
//                             width: 3,
//                           ),
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           if (sub.image != null)
//                             Image.network(sub.image!, height: 40),
//                           const SizedBox(height: 4),
//                           Text(
//                             sub.name,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: isSelected ? Colors.orange : Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//            Expanded(
//   child: products.isEmpty
//       ? const Center(
//           child: Text('No products available'),
//         )
//       : GridView.builder(
//           padding: const EdgeInsets.all(12),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             mainAxisSpacing: 12,
//             crossAxisSpacing: 12,
//             childAspectRatio: 0.6,
//           ),
//           itemCount: products.length,
//           itemBuilder: (context, index) {
//             final product = products[index];
//             final quantity = home.getQuantity(product.id);

//             const double imageHeight = 120; 

//             return GestureDetector(
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => ProductDetailScreen(
              //         productId: product.id,
              //         subCategories: selectedSubCategory,
              //       ),
              //     ),
              //   );
              // },
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   // boxShadow: const [
//                   //   BoxShadow(
//                   //     color: Colors.black12,
//                   //     blurRadius: 4,
//                   //     offset: Offset(0, 2),
//                   //   )
//                   // ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // IMAGE + ADD BUTTON
//                     Stack(
//                       children: [
//                         ClipRRect(
//                           borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(12),
//                           ),
//                           child: isValidImage(product.imagePath)
//                               ? Image.network(
//                                   product.imagePath,
//                                   height: imageHeight,
//                                   width: double.infinity,
//                                   fit: BoxFit.cover,
//                                 )
//                               : Container(
//                                   height: imageHeight,
//                                   width: double.infinity,
//                                   color: Colors.grey[200],
//                                   child: const Icon(
//                                     Icons.image,
//                                     size: 40,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                         ),

//                         // ADD / QUANTITY BUTTON
//                         Positioned(
//                           bottom: 8,
//                           right: 8,
//                           child: quantity == 0
//                               ? InkWell(
//                                   onTap: () =>
//                                       home.incrementQuantity(product.id),
//                                   child: Container(
//                                     height: 32,
//                                     width: 44,
//                                     alignment: Alignment.center,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(
//                                         color:
//                                             AppColors.primaryOrangeColor,
//                                         width: 2,
//                                       ),
//                                     ),
//                                     child: const Icon(
//                                       Icons.add,
//                                       size: 18,
//                                       color:
//                                           AppColors.primaryOrangeColor,
//                                     ),
//                                   ),
//                                 )
//                               : Container(
//                                   height: 32,
//                                   width: 70,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 6),
//                                   decoration: BoxDecoration(
//                                     color:
//                                         AppColors.primaryOrangeColor,
//                                     borderRadius:
//                                         BorderRadius.circular(8),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       InkWell(
//                                         onTap: () => home
//                                             .decrementQuantity(
//                                                 product.id),
//                                         child: const Icon(
//                                           Icons.remove,
//                                           size: 14,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 6),
//                                         child: Text(
//                                           '$quantity',
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                       InkWell(
//                                         onTap: () => home
//                                             .incrementQuantity(
//                                                 product.id),
//                                         child: const Icon(
//                                           Icons.add,
//                                           size: 14,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 8),

//                     // DETAILS
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // PRICE ROW
//                           Row(
//                             children: [
//                               Container(
//                                 padding:
//                                     const EdgeInsets.symmetric(
//                                         horizontal: 10, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.green[700],
//                                   borderRadius:
//                                       BorderRadius.circular(4),
//                                 ),
//                                 child: Text(
//                                   "₹${product.salePrice}",
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               if (product.basePrice >
//                                   product.salePrice)
//                                 Text(
//                                   "₹${product.basePrice}",
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey[600],
//                                     decoration:
//                                         TextDecoration.lineThrough,
//                                   ),
//                                 ),
//                             ],
//                           ),

//                           const SizedBox(height: 8),
//                           Row(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   product.name,
//                                   maxLines: 1,
//                                   overflow:
//                                       TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w600,
//                                     height: 1.2,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               if (product.weight != null)
//                                 Text(
//                                   "${product.weight!.value}${product.weight!.unit}",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
// ),

//           ],
//         ),
//         bottomNavigationBar: Consumer<Home>(
//           builder: (context, provider, _) {
//             return provider.hasItems
//                 ? const BottomStickyContainer()
//                 : const SizedBox.shrink();
//           },
//         ),
//         // bottomNavigationBar: BottomStickyContainer(),
//       );
//     });
//   }
// }
                        
                         