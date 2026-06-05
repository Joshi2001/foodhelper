import 'dart:convert';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Models/discount_range.dart';
import '../../../Models/product.dart';
import '../../../app_colors.dart';
import 'package:http/http.dart' as http;

class BulkDiscountDialog2 extends StatefulWidget {
  final List<DiscountRange> ranges;
  final Product product;

  const BulkDiscountDialog2({
    super.key,
    required this.ranges,
    required this.product,
  });

  @override
  State<BulkDiscountDialog2> createState() => _BulkDiscountDialogState();
}

class _BulkDiscountDialogState extends State<BulkDiscountDialog2> {
  late Future<List<DiscountRange>> _discountsFuture;

  Future<List<DiscountRange>> fetchDiscounts(String productId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://grocerrybackend.onrender.com/api/public/pricing/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];

        debugPrint("Data length: ${data.length}");

        // Debug each item
        for (var item in data) {
          debugPrint("Item: $item");
          debugPrint("minQty: ${item['minQty']}");
          debugPrint("maxQty: ${item['maxQty']}");
          debugPrint("price: ${item['price']}");
          debugPrint("discount: ${item['discount']}");
        }

        return data
            .where((d) => d is Map<String, dynamic> && d['minQty'] != null)
            .map((d) => DiscountRange.fromJson(d))
            .toList();
      } else {
        throw Exception(
            "Failed to load discounts (Status: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("fetchDiscounts error: $e");
      rethrow;
    }
  }

  DiscountRange? getActiveDiscountRange(List<DiscountRange> ranges,
      int quantity) {
    for (var range in ranges) {
      if (quantity >= range.min && (range.max == -1 || quantity <= range.max)) {
        return range;
      }
    }
    return null;
  }

  String getPriceText(DiscountRange? activeRange,
      Product product,
      int quantity,) {
    if (activeRange != null && activeRange.price > 0) {
      return "₹${activeRange.price.toStringAsFixed(2)}";
    }

    return "₹${product.salePrice.toStringAsFixed(2)}";
  }

  @override
  void initState() {
    super.initState();
    _discountsFuture = fetchDiscounts(widget.product.id).then((ranges) {
      // ✅ Cache into provider taaki CartScreen mein sahi price aaye
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<Home>(context, listen: false)
              .cacheBulkRanges(widget.product.id, ranges);
        }
      });
      return ranges;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiscountRange>>(
      future: _discountsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading discounts..."),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                  ),
                ],
              ),
            ),
          );
        }

        final ranges = snapshot.data ?? [];

        return Consumer<Home>(
          builder: (context, homeProvider, child) {
            final currentQuantity = homeProvider.getQuantity(widget.product.id);

            final activeRange = getActiveDiscountRange(ranges, currentQuantity);

            final priceText =
            getPriceText(activeRange, widget.product, currentQuantity);

            final currentDiscountPercent = activeRange?.discountPercent ?? 0;

            final originalUnitPrice = widget.product.salePrice;
            final discountPerUnit =
                originalUnitPrice * (currentDiscountPercent / 100);
            final totalDiscount = discountPerUnit * currentQuantity;

            return Dialog(
              insetPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade600,
                                  Colors.green.shade400,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.discount,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Bulk Pricing Discounts",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${widget.product.name} - Save more!",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            color: Colors.grey,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (currentQuantity > 0)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Current Cart Quantity",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        "$currentQuantity units",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: activeRange != null &&
                                              currentDiscountPercent > 0
                                              ? Colors.orange
                                              .shade100
                                              : Colors.green
                                              .shade100,
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          priceText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: activeRange != null &&
                                                currentDiscountPercent > 0
                                                ? Colors.orange
                                                .shade800
                                                : Colors.green
                                                .shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (activeRange != null &&
                                      currentDiscountPercent > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "Original: ₹${originalUnitPrice
                                            .toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                          decoration:
                                          TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (currentDiscountPercent > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Total Saving",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        "₹${totalDiscount.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "$currentDiscountPercent% off",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // ── Table Header ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Range",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Price",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Discount",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Table Rows ───────────────────────────────────
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                          Border.all(color: Colors.grey.shade200, width: 2),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: ranges.isEmpty
                              ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0),
                              child: Text(
                                "No discount ranges available",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ]
                              : ranges
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final range = entry.value;
                            final isLast = index == ranges.length - 1;
                            final isActive =
                                currentQuantity >= range.min &&
                                    (range.max == -1 ||
                                        currentQuantity <= range.max);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.shade100
                                    : Colors.white,
                                border: isLast
                                    ? null
                                    : Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        if (isActive) ...[
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: Colors.green.shade700,
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        Expanded(
                                          child: Text(
                                            range.rangeText,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isActive
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: isActive
                                                  ? Colors.green.shade800
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      range.priceText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isActive
                                            ? Colors.green.shade800
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      range.discountText,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: range.discountPercent <= 0
                                            ? Colors.grey
                                            : Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── SLEEK QUICK ADD SECTION ────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          // Halka sa background difference
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.flash_on, size: 16,
                                    color: Colors.orange),
                                SizedBox(width: 6),
                                Text(
                                  "Quick Adjust",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
            Row(
            children: [
            Expanded(
            child: _buildQuickAddButton(
            context,
            homeProvider,
            "+5",
            5,
            Icons.add_circle_outline, // Icon add kar diya
            isMinus: false,
            ),
            ),
            const SizedBox(width: 8),
            Expanded(
            child: _buildQuickAddButton(
            context,
            homeProvider,
            "+10",
            10,
            Icons.add_box_outlined, // Icon add kar diya
            isMinus: false,
            ),
            ),
            const SizedBox(width: 8),
            Expanded(
            child: _buildQuickAddButton(
            context,
            homeProvider,
            "-5",
            5,
            Icons.remove_circle_outline, // Icon add kar diya
            isMinus: true,
            ),
            ),
            ],
            ),
                      const SizedBox(height: 20),

// ── SLIM MAIN COUNTER ────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 40, // Height kam kar di (44 se 40)
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Minus Button
                                InkWell(
                                  onTap: () {
                                    if (currentQuantity > 0) {
                                      homeProvider.decrementQuantity(
                                          widget.product.id);
                                      homeProvider.loadCart();
                                    }
                                  },
                                  child: Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: currentQuantity > 0 ? Colors.red
                                          .shade50 : Colors.grey.shade100,
                                      borderRadius: const BorderRadius
                                          .horizontal(left: Radius.circular(9)),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: currentQuantity > 0
                                          ? Colors.red
                                          : Colors.grey.shade400,
                                      size: 18,
                                    ),
                                  ),
                                ),

                                // Quantity Display
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "$currentQuantity",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),

                                // Plus Button
                                InkWell(
                                  onTap: () {
                                    homeProvider.incrementQuantity(
                                        widget.product.id);
                                    homeProvider.loadCart();
                                  },
                                  child: Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: const BorderRadius
                                          .horizontal(
                                          right: Radius.circular(9)),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // ── Done Button ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: SizedBox(
                            height: 44,
                            width: 250,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(
                                      currentQuantity > 0),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: currentQuantity > 0
                                    ? AppColors.primaryOrangeColor
                                    : Colors.grey.shade300,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      25), // Fully rounded for premium look
                                ),
                              ),
                              child: const Text(
                                  "Done",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 0.5
                                  )
                              ),
                            ),
                          ),
                        ),

                      ),
                    ],
                  ),
                ),
             ] ),
                    ),
            )
            );
          },
        );
      },
    );
  }

  Widget _buildQuickAddButton(BuildContext context,
      Home homeProvider,
      String label,
      int quantity,
      IconData icon, {
        bool isMinus = false,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        for (int i = 0; i < quantity; i++) {
          if (isMinus) {
            homeProvider.decrementQuantity(widget.product.id);
          } else {
            homeProvider.incrementQuantity(widget.product.id);
          }
        }
        homeProvider.loadCart();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          // Logic ke hisaab se colors maintain kiye hain
          color: isMinus ? Colors.red.shade50 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isMinus ? Colors.red.shade100 : Colors.green.shade100,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                icon,
                size: 18, // Size chota kiya taaki sleek lage
                color: isMinus ? Colors.red.shade700 : Colors.green.shade700
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12, // Font size adjust kiya
                fontWeight: FontWeight.bold,
                color: isMinus ? Colors.red.shade900 : Colors.green.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}