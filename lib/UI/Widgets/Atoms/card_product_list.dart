import 'package:e_commerce/Models/discount_range.dart';
import 'package:e_commerce/Models/product.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/bulk_dialiog2.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductCardForList extends StatelessWidget {
  final Product product;
  final double padding;
  final bool isHome;
  final bool isCart;
  final int index;

  const ProductCardForList({
    super.key,
    required this.index,
    required this.product,
    this.padding = 5,
    this.isHome = false,
    this.isCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Home>(
      builder: (context, homeProvider, child) {
        final quantity = homeProvider.getQuantity(product.id);
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product/detail',
              arguments: product.id,
            );
          },
          child: Card(
            color: Colors.white,
            child: Container(
              constraints: BoxConstraints(maxHeight: 220, minWidth: 150),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  product.imagePath,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: padding,
                              right: padding,
                              top: 0,
                              bottom: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                // Show price for both home and cart
                                SizedBox(
                                  height: 25,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        quantity > 0
                                            ? '₹ ${product.currentPrice * quantity}'
                                            : '₹ ${product.currentPrice}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isHome)
                    Positioned(
                      top: -5,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => showBulkDiscountPopup(
                          context,
                          product.bulkPricing,
                          product,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.green, Colors.green],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_offer_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Bulk Price",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Add/Quantity Button Section
                  isHome
                      ? Positioned(
                          left: 10,
                          right: 10,
                          bottom: 5,
                          child: _buildAddToCartButton(
                            context,
                            homeProvider,
                            quantity,
                            product,
                            isHome: true,
                          ),
                        )
                      : Positioned(
                          bottom: 5,
                          right: 10,
                          left: 10,
                          child: Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: quantity != 0 ? 0 : 10,
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(60, 32),
                                  elevation: 2,
                                ),
                                onPressed: () => showBulkDiscountPopup(
                                  context,
                                  product.bulkPricing,
                                  product,
                                ),
                                child: const Text(
                                  "Bulk Price",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                              const Spacer(),
                              _buildAddToCartButton(
                                context,
                                homeProvider,
                                quantity,
                                product,
                                isHome: false,
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddToCartButton(
    BuildContext context,
    Home homeProvider,
    int quantity,
    Product product, {
    required bool isHome,
  }) {
    if (quantity == 0) {
      return InkWell(
        onTap: () {
          homeProvider.incrementQuantity(product.id);
          homeProvider.getCartItemsLocal();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryOrangeColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'ADD',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primaryOrangeColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: isHome ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                homeProvider.decrementQuantity(product.id);
              },
              child: Container(
                width: 28,
                height: 32,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.remove,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 24),
              alignment: Alignment.center,
              child: Text(
                '$quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                homeProvider.incrementQuantity(product.id);
              },
              child: Container(
                width: 28,
                height: 32,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

void showBulkDiscountPopup(
  BuildContext context,
  List<DiscountRange> ranges,
  Product product,
) {
  showDialog(
    context: context,
    builder: (_) => BulkDiscountDialog2(
      ranges: ranges,
      product: product,
    ),
  );
}
