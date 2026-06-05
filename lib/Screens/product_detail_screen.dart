import 'package:e_commerce/Models/category_model.dart';
import 'package:e_commerce/Services/Providers/cart_provider.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/card_product_list.dart';
import 'package:e_commerce/UI/Widgets/Organisms/bottom_cart_container.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final SubCategory subCategories;

  const ProductDetailScreen({   
    super.key,
    required this.productId,
    required this.subCategories,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Home>().fetchProductById(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Home>(
      builder: (context, home, _) {
        final product = home.selectedProduct;

        if (home.isLoadingProducts) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (product == null) {
          return const Scaffold(
            body: Center(child: Text('Product not found')),
          );
        }

        final quantity = home.getQuantity(product.id);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[100],
                  child: ClipRRect(
                    child: Image.network(
                      product.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Bulk Offers Badge
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Bulk Offers Available',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Weight and Category
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.weight != null
                                  ? "${product.weight!.value}${product.weight!.unit}"
                                  : "N/A",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primaryOrangeColor,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.subCategories.name, // Display subcategory name
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryOrangeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Original Price with strikethrough
                      Row(
                        children: [
                          Text(
                            '₹${product.basePrice}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      quantity == 0
                          ? Text(
                              '₹${product.salePrice}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              '₹${product.salePrice * quantity}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              showBulkDiscountPopup(
                                context,
                                product.bulkPricing,
                                product,
                              );
                            },
                            icon: const Icon(Icons.local_offer, size: 18),
                            label: const Text('Bulk Price'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Add/Quantity Button
                          Expanded(
                            child: quantity == 0
                                ? ElevatedButton(
                                    onPressed: () {
                                      home.incrementQuantity(product.id);
                                      // context
                                      //     .read<CartProvider>()
                                      //     .loadCartFromHome(
                                      //       home.getCartItemsLocal(),
                                      //     );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.primaryOrangeColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Text(
                                      'ADD',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrangeColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            home.decrementQuantity(product.id);
                                            // context
                                            //     .read<CartProvider>()
                                            //     .loadCartFromHome(
                                            //       home.getCartItemsLocal(),
                                            //     );
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 12,
                                            ),
                                            child: Icon(
                                              Icons.remove,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        quantity == 0
                                            ? Text(
                                                '${quantity + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : Text(
                                                '$quantity',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                        InkWell(
                                          onTap: () {
                                            home.incrementQuantity(product.id);
                                            // context
                                            //     .read<CartProvider>()
                                            //     .loadCartFromHome(
                                            //       home.getCartItemsLocal(),
                                            //     );
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 12,
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$quantity items in cart',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'High-quality ${product.name} perfect for daily use. This product is carefully sourced and packed to ensure freshness and quality. Ideal for bulk purchases with attractive discounts on larger quantities.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        '100% Authentic Product',
                        Icons.check_circle,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailItem(
                        'Fast Delivery Available',
                        Icons.local_shipping,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailItem(
                        'Easy Returns & Refunds',
                        Icons.assignment_return,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailItem(
                        'Bulk Discounts Available',
                        Icons.card_giftcard,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomStickyContainer(),
        );
      },
    );
  }

  Widget _buildDetailItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
