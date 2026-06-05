import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyWhiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryIndigoColor.shade700,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryIndigoColor.shade700,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          'Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (ctx, index) {
          final isDelivered = index % 2 == 0;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(
                    orderId: 'ORD00${index + 1}',
                    status: isDelivered ? 'Delivered' : 'Pending',
                    date: '${DateTime.now().day - index} Nov 2025',
                    itemsCount: index + 2,
                    total: (index + 1) * 250,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #ORD00${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDelivered
                                ? Colors.green.shade100
                                : AppColors.primaryIndigoColor.shade100.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isDelivered ? 'Delivered' : 'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDelivered
                                  ? Colors.green.shade700
                                  : AppColors.primaryIndigoColor.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          '${DateTime.now().day - index} Nov 2025',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 20),
                        Icon(Icons.shopping_bag, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          '${index + 2} items',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total: ₹${(index + 1) * 250}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryIndigoColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String status;
  final String date;
  final int itemsCount;
  final int total;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
    required this.status,
    required this.date,
    required this.itemsCount,
    required this.total,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String _currentStatus;

  final List<String> _statusOptions = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green.shade100;
      case 'Cancelled':
        return Colors.red.shade100;
      case 'Shipped':
        return Colors.blue.shade100;
      case 'Processing':
        return Colors.orange.shade100;
      default:
        return AppColors.primaryIndigoColor.shade100.withOpacity(0.5);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green.shade700;
      case 'Cancelled':
        return Colors.red.shade700;
      case 'Shipped':
        return Colors.blue.shade700;
      case 'Processing':
        return Colors.orange.shade700;
      default:
        return AppColors.primaryIndigoColor.shade800;
    }
  }

  void _showEditStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.all(5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: AppColors.primaryIndigoColor),
            const SizedBox(width: 8),
            const Text('Update Order Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusOptions.map((status) {
            return RadioListTile<String>(
              title: Text(status),
              value: status,
              groupValue: _currentStatus,
              activeColor: AppColors.primaryIndigoColor,
              onChanged: (value) {
                setState(() {
                  _currentStatus = value!;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order status updated to: $value'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDelivered = _currentStatus == 'Delivered';
    return Scaffold(
      backgroundColor: AppColors.greyWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryIndigoColor.shade700,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryIndigoColor.shade700,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order ID',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                    ),
                    Text(
                      widget.orderId,
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryIndigoColor),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // STATUS ROW WITH EDIT BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_currentStatus),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentStatus,
                            style: TextStyle(
                              color: _getStatusTextColor(_currentStatus),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _showEditStatusDialog,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryIndigoColor.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: AppColors.primaryIndigoColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                    Text(widget.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Items', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                    Text('${widget.itemsCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                    Text(
                      '₹${widget.total}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryIndigoColor),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Customer Details',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryIndigoColor.shade100,
                    child: Icon(Icons.person, color: AppColors.primaryIndigoColor),
                  ),
                  title: const Text('Jane Smith'),
                  subtitle: const Text('jane.smith@example.com'),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigoColor,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  label: const Text('Contact Customer', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
