import 'package:e_commerce/Models/category_model.dart';
import 'package:e_commerce/Models/product.dart';
import 'package:flutter/material.dart';
import '../Atoms/card_product_list.dart';

// Widget buildProductsGrid(List<Product> cast) {
//   return CustomScrollView(
//     shrinkWrap: true,
//     physics: const BouncingScrollPhysics(),
//     slivers: [
//       SliverGrid(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 2,
//           crossAxisSpacing: 2,
//           childAspectRatio: 0.55,
//         ),
//         delegate: SliverChildBuilderDelegate(
//           (BuildContext context, int index) {
//             if (index == 6) {
//               return const SizedBox(
//                 height: 50,
//               );
//             }

//             return ProductCardForList(
//               index: index,
//               isHome:true,
//               padding: 5,
//             );
//           },
//           childCount: 6 + 1,
//         ),
//       )
//     ],
//   );
// }


Widget buildProductsGrid(List<Product> products) {
  if (products.isEmpty) {
    return const SliverToBoxAdapter(
      child: Center(child: Text('No products found')),
    );
  }

  return CustomScrollView(
    shrinkWrap: true,
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 0.55,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ProductCardForList(
              product: products[index],  
              isHome: true,
              padding: 5, index: index,
            );
          },
          childCount: products.length,
        ),
      ),
    ],
  );
}
