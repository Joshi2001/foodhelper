import 'package:e_commerce/Models/order.dart';
import 'package:e_commerce/Screens/order_summary_screen.dart';
import 'package:e_commerce/Services/Providers/orderprovider.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    if (mounted) {
      await Provider.of<OrderProvider>(context, listen: false)
          .fetchMyOrders(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.greyWhiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryOrangeColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (_) => false),
          ),
          title: const Text('Your Orders',
              style: TextStyle(fontSize: 20, color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadOrders,
            ),
          ],
        ),
        body: Consumer<OrderProvider>(
          builder: (_, provider, __) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                        Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadOrders,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrangeColor),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (provider.orders.isEmpty) return _emptyOrders(context);

            return RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.orders.length,
                itemBuilder: (_, index) =>
                    _orderCard(context, provider.orders[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyOrders(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 90,
              color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('No orders yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Start shopping to place your first order',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (_) => false),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrangeColor),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(BuildContext context, Order order) {
    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Top Header Section (Status & Date) ────────────────
            Container(
              padding: const EdgeInsets.all(16),
              color: order.statusColor.withOpacity(0.06),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: order.statusColor.withOpacity(0.2),
                            blurRadius: 4)
                      ],
                    ),
                    child: Icon(
                        order.statusIcon, color: order.statusColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.statusText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: order.statusColor,
                          ),
                        ),
                        Text(
                          dateFormat.format(order.orderDate),
                          style: TextStyle(fontSize: 11, color: Colors.grey
                              .shade600),
                        ),
                      ],
                    ),
                  ),
                  // Order Total Amount on Right
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${order.finalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (order.hasCoupon)
                        Text(
                          '₹${order.originalTotalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Coupon Badge (Only if applied)
                  if (order.hasCoupon) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FFF4), // Light Emerald
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.confirmation_num_outlined, size: 16,
                              color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Coupon Applied: ${order.couponCode}',
                              style: const TextStyle(fontSize: 12,
                                  color: Color(0xFF166534),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '-₹${order.couponDiscount.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Product List Section ──────────────────────────
                  const Text("Items Ordered", style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
                  const SizedBox(height: 10),

                  ...order.items.take(2).map((item) =>
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image with border
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                                image: DecorationImage(
                                  image: NetworkImage(item.productImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF374151)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity}  •  ₹${item.unitPrice
                                        .toStringAsFixed(0)} per pc',
                                    style: TextStyle(fontSize: 11,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${item.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      )),

                  if (order.items.length > 2)
                    Center(
                      child: Text(
                        'and ${order.items.length - 2} more item${order.items
                            .length - 2 > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 11,
                            color: AppColors.primaryOrangeColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5),
                  ),

                  // ── Payment & Footer Actions ───────────────────────
                  Row(
                    children: [
                      Icon(
                          Icons.payment, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        order.paymentMode.toUpperCase(),
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: order.paymentStatus == 'paid' ? Colors.green
                              .shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.paymentStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: order.paymentStatus == 'paid' ? Colors.green
                                .shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) =>
                              OrderDetailsScreen(order: order)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryOrangeColor,
                        elevation: 0,
                        side: BorderSide(color: AppColors.primaryOrangeColor
                            .withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Track or View Details', style: TextStyle(
                              fontWeight: FontWeight.w800)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 12),
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
  }
}