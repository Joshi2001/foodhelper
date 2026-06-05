import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../app_colors.dart';

class CartScreenPaymentContainer extends StatelessWidget {
  const CartScreenPaymentContainer({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Row(
            children: [
              Icon(
                Icons.payment,
                color: AppColors.primaryOrangeColor,
              ),
              SizedBox(
                width: 15,
              ),
            GestureDetector(
                onTap: (){
                  Navigator.of(context).pushNamed('/payment-option');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Row(
                        children: [
                          Text(      "Payment Method",
                          style: TextStyle(fontWeight: FontWeight.bold),
                                            ),

                          Icon(Icons.keyboard_arrow_down_outlined )

                        ],
                      ),
                    Text(
                      "Google Pay",
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              )
            ],
          ),
          ElevatedButton(
            onPressed: () {
              print('object');
              Navigator.of(context).pushNamed('/order/confirm');
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryOrangeColor,
              foregroundColor: AppColors.greyWhiteColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
            ),
            child: const Text("Place Order"),
          )
        ],
      ),
    );
  }
}





