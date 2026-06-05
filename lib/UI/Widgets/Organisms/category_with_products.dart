import 'package:e_commerce/Models/product.dart';
import 'package:e_commerce/UI/Widgets/Atoms/card_product_list.dart';
import 'package:flutter/material.dart';

class CategoryWithProducts extends StatelessWidget {
  final String title;
  final List<Product> products;
  final bool isLoading;

  const CategoryWithProducts({
    super.key,
    required this.title,
    required this.products,
    this.isLoading = false, 
    String? categoryId,
  });

  @override
  Widget build(BuildContext context) {
    print('Category: $title | Products count: ${products.length}');
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (products.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 100,
          child: Center(child: Text('No products available')),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              itemCount: products.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
              child: ProductCardForList(
                    product: products[index],
                    isHome: true,
                    padding: 5,
                    index: index,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}