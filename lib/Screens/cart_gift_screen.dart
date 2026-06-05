import 'dart:convert';
import 'package:e_commerce/UI/Widgets/address/add_address.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:e_commerce/UI/Widgets/Atoms/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartGiftScreen extends StatefulWidget {
  const CartGiftScreen({super.key});

  @override
  State<CartGiftScreen> createState() => _CartGiftScreenState();
}

class _CartGiftScreenState extends State<CartGiftScreen> {
  Map<String, dynamic>? savedGiftAddress;
  String? savedContactNumber;
  String? giftMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedGiftData();
  }

  Future<void> _loadSavedGiftData() async {
    final prefs = await SharedPreferences.getInstance();
    final giftAddressJson = prefs.getString('gift_address');
    final giftContact = prefs.getString('gift_contact');
    final giftMsg = prefs.getString('gift_message');

    setState(() {
      if (giftAddressJson != null) {
        savedGiftAddress = jsonDecode(giftAddressJson);
      }
      savedContactNumber = giftContact;
      giftMessage = giftMsg;
    });
  }

  Future<void> _saveGiftAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddress(
          onAddressSelected: (addressData) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('gift_address', jsonEncode(addressData));
            await _loadSavedGiftData();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gift address saved!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Cleaner background
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrangeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Gift Options",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Premium Header Image ---
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrangeColor.withOpacity(0.1),
                  ),
                  child: Image.asset(
                    "Assets/Images/gift.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Send a Surprise",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fill in the details to make your gift special",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Steps Section ---
                  _buildStepWrapper(
                    child: OrderAsGiftStepCard(
                      title: "Delivery Address",
                      subtitle: savedGiftAddress != null
                          ? _formatGiftAddress(savedGiftAddress!)
                          : "Where should we send the gift?",
                      icon: Icons.location_on_rounded,
                      isCompleted: savedGiftAddress != null,
                      onTap: _saveGiftAddress,
                    ),
                    isLast: false,
                  ),
                  _buildStepWrapper(
                    child: OrderAsGiftStepCard(
                      title: "Contact Number",
                      subtitle: savedContactNumber != null && savedContactNumber!.isNotEmpty
                          ? savedContactNumber!
                          : "Recipient's phone for tracking",
                      icon: Icons.phone_android_rounded,
                      isCompleted: savedContactNumber != null && savedContactNumber!.isNotEmpty,
                      onTap: () => _showContactNumberDialog(),
                    ),
                    isLast: false,
                  ),
                  _buildStepWrapper(
                    child: OrderAsGiftStepCard(
                      title: "Gift Message",
                      subtitle: giftMessage != null && giftMessage!.isNotEmpty
                          ? giftMessage!
                          : "Write a sweet note for them",
                      icon: Icons.auto_awesome_rounded,
                      isCompleted: giftMessage != null && giftMessage!.isNotEmpty,
                      onTap: () => _showGiftMessageDialog(),
                    ),
                    isLast: true,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: customTextButton(
          context,
          callback: () {
            Navigator.pop(context, {
              'address': savedGiftAddress,
              'contact': savedContactNumber,
              'message': giftMessage,
            });
          },
          title: "Save & Continue",
          color: AppColors.primaryOrangeColor,
        ),
      ),
    );
  }

  // Helper to wrap steps with a visual line
  Widget _buildStepWrapper({required Widget child, required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child),
        ],
      ),
    );
  }

  String _formatGiftAddress(Map<String, dynamic> address) {
    final parts = [
      address['house'] ?? '',
      address['building'] ?? '',
      address['address'] ?? '',
    ].where((e) => e.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Address saved';
  }

  void _showContactNumberDialog() {
    final controller = TextEditingController(text: savedContactNumber);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recipient's Contact", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter 10-digit number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('gift_contact', controller.text);
                  await _loadSavedGiftData();
                  if (mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrangeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Save Number", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  void _showGiftMessageDialog() {
    final controller = TextEditingController(text: giftMessage);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add a Message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your heart out...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('gift_message', controller.text);
                  await _loadSavedGiftData();
                  if (mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrangeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Save Message", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

class OrderAsGiftStepCard extends StatelessWidget {
  const OrderAsGiftStepCard({
    super.key,
    this.title = "",
    this.subtitle = "",
    this.icon,
    this.isCompleted = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withOpacity(0.1) : AppColors.primaryOrangeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle_rounded : (icon ?? Icons.add),
                  color: isCompleted ? Colors.green : AppColors.primaryOrangeColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green.shade700 : const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                isCompleted ? Icons.edit_note_rounded : Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 18,
              )
            ],
          ),
        ),
      ),
    );
  }
}