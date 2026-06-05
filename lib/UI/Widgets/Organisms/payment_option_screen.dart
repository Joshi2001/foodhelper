import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app_colors.dart';

class PaymentOptionsScreen extends StatelessWidget {
  const PaymentOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrangeColor,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Payment Options",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: AppColors.greyWhiteColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Pay by UPI"),
            _customCard(
              children: [
                _tileWithIcon(
                  icon: FontAwesomeIcons.rupeeSign,
                  title: "Pay by any UPI app",
                  subtitle: "Use any UPI app on the phone to pay",
                ),
                const Divider(),
                _tileWithIcon(
                  icon: FontAwesomeIcons.google,
                  title: "GPay",
                ),
                const Divider(),
                _addNewButton("Add New UPI ID"),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle("Pluxee"),
            _customCard(
              children: [
                _tileWithIcon(
                  icon: FontAwesomeIcons.creditCard,
                  title: "Pluxee",
                  subtitle: "There are non food items in the cart",
                  trailing: "Currently Ineligible",
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle("Credit & Debit Cards"),
            _customCard(
              children: [
                _addNewButton("Add New Card", subtitle: "Visa, Mastercard, Rupay & more"),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle("Wallets"),
            _customCard(
              children: [
                _tileWithIcon(
                  icon: FontAwesomeIcons.phoneFlip, // closest wallet icon
                  title: "PhonePe Wallet",
                ),
                const Divider(),
                _tileWithIcon(
                  icon: FontAwesomeIcons.amazon,
                  title: "Amazon Pay Balance",
                  trailingText: "LINK",
                  trailingColor: Colors.pink,
                ),
                const Divider(),
                _viewMore("View More Wallets"),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle("Pay Later"),
            _customCard(
              children: [
                _tileWithIcon(
                  icon: FontAwesomeIcons.clock,
                  title: "LazyPay",
                  subtitle: "Currently Ineligible",
                ),
                const Divider(),
                _tileWithIcon(
                  icon: FontAwesomeIcons.amazon,
                  title: "Amazon Pay Later",
                  trailingText: "LINK",
                  trailingColor: Colors.pink,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle("Netbanking"),
            _customCard(
              children: [
                _netbankRow([
                  FontAwesomeIcons.buildingColumns, // generic bank icon
                  FontAwesomeIcons.creditCard,      // generic card icon as placeholder
                  FontAwesomeIcons.moneyBill,        // money bill icon
                  FontAwesomeIcons.piggyBank,        // piggy bank icon as placeholder
                ]),
                const Divider(),
                _viewMore("View More Banks"),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle("Cash on Delivery"),
            _customCard(
              children: [
                _tileWithIcon(
                  icon: FontAwesomeIcons.moneyBillWave,
                  title: "Pay by Cash / UPI on delivery",
                  subtitle: "COD is not available",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _customCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4), // minimal vertical padding inside card
      child: Column(children: children),
    );
  }

  Widget _tileWithIcon({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    Color trailingColor = Colors.grey,
    String? trailing,
  }) {
    return ListTile(
      minTileHeight: 35,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // very small vertical padding
      leading: FaIcon(icon, size: 20, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailingText != null
          ? Text(trailingText, style: TextStyle(color: trailingColor, fontWeight: FontWeight.bold, fontSize: 13))
          : trailing != null
          ? Text(trailing, style: const TextStyle(color: Colors.grey, fontSize: 13))
          : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    );
  }

  Widget _addNewButton(String title, {String? subtitle}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.shade50,
        ),
        // padding: const EdgeInsets.all(4), // smaller padding inside circle
        child: const Icon(Icons.add, color: Colors.pink, size: 18), // smaller plus icon
      ),
      title: Text(title, style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
    );
  }

  Widget _viewMore(String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      leading: const Icon(Icons.keyboard_arrow_down, color: Colors.pink, size: 20),
      title: Text(title, style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _netbankRow(List<IconData> icons) {
    return Padding(
      padding: const EdgeInsets.all(8), // reduced padding here as well
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: icons.map((icon) => FaIcon(icon, size: 24)).toList(), // smaller bank icons
      ),
    );
  }

}
