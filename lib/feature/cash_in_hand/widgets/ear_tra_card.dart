import 'package:flutter/material.dart';
import 'package:stackfood_multivendor_driver/feature/cash_in_hand/controllers/cash_in_hand_controller.dart';

import '../../../helper/date_converter_helper.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class EarningTransactionCard extends StatelessWidget {

  final double amount;
  final String date;
  final String orderId;

  const EarningTransactionCard({super.key,  required this.amount, required this.date, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeLarge),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    PriceConverter.convertPrice(amount),
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault),
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(
                      height:
                      Dimensions.paddingSizeExtraSmall),
                  Text(
                      '${orderId}',
                      style: robotoRegular.copyWith(
                        fontSize:
                        Dimensions.fontSizeExtraSmall,
                        color:
                        Theme.of(context).disabledColor,
                      )),
                ]),
          ),


          Text(
           date,
            style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).disabledColor),
          ),
        ]),
      ),
      const Divider(height: 1),
    ]);
  }
}
