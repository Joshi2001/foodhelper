import 'package:flutter/material.dart';
import '../app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static final List<_NotificationData> dummyNotifications = [
    _NotificationData(
      title: "Order Delivered",
      body: "Your order #ORD1234 has been delivered successfully.",
      time: "2 hours ago",
      icon: Icons.check_circle_outline,
      isUnread: true,
    ),
    _NotificationData(
      title: "Big 50% OFF Sale!",
      body: "Get the best deals on groceries this week. Hurry, offer for limited time!",
      time: "Today, 10:00 AM",
      icon: Icons.local_offer_outlined,
      isUnread: true,
    ),
    _NotificationData(
      title: "Payment Received",
      body: "Your payment for order #ORD1233 is complete.",
      time: "Yesterday, 5:22 PM",
      icon: Icons.account_balance_wallet_outlined,
      isUnread: false,
    ),
    _NotificationData(
      title: "Welcome to Blinkit Style!",
      body: "Thanks for signing up. Start shopping for fastest grocery delivery!",
      time: "2 days ago",
      icon: Icons.notifications_active_outlined,
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyWhiteColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColors.primaryOrangeColor,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: dummyNotifications.length,
        itemBuilder: (context, index) {
          final note = dummyNotifications[index];
          return Card(
            elevation: note.isUnread ? 2 : 0.2,
            margin: const EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, right: 2, bottom: 3, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Orange icon and unread badge, slightly smaller than before
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrangeColor.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(
                          note.icon,
                          color: AppColors.primaryOrangeColor,
                          size: 21,
                        ),
                      ),
                      if (note.isUnread)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Content Top Aligned
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: TextStyle(
                            fontWeight: note.isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 14.5,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          note.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey[850],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note.time,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (note.isUnread)
                    const Padding(
                      padding: EdgeInsets.only(left: 2, top: 2),
                      child: Icon(Icons.circle, size: 10, color: Colors.green),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationData {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final bool isUnread;

  _NotificationData({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.isUnread,
  });
}
