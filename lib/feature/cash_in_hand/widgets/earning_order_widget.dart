import 'package:flutter/material.dart';
import 'package:stackfood_multivendor_driver/feature/cash_in_hand/widgets/ear_tra_card.dart';

import '../../../helper/date_converter_helper.dart';

import '../controllers/cash_in_hand_controller.dart';

class EarningOrderWidget extends StatelessWidget {
  final CashInHandController cashInHandController;
  const EarningOrderWidget({super.key, required this.cashInHandController});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('Earning'),
      child: Column(
        children: [
          cashInHandController.deliveryCharges == null
              ? const Center(
                  child: CircularProgressIndicator()) // Show loader if loading
              : cashInHandController.deliveryCharges!.isNotEmpty
                  ? ListView.builder(
                      itemCount:
                          cashInHandController.deliveryCharges!.length > 25
                              ? 25
                              : cashInHandController.deliveryCharges!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        String dateTime= DateConverter.orderDateTime(
                            cashInHandController
                                .deliveryCharges![index].date
                                .toString(),
                            cashInHandController
                                .deliveryCharges![index].time
                                .toString());
                        return EarningTransactionCard(

                            amount: cashInHandController.deliveryCharges![index]
                                    .deliveryFeeEarned ??
                                0,
                            date: dateTime ??
                                "",
                            orderId:'OrderID#${cashInHandController
                                    .deliveryCharges![index].orderId
                            } ');
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Text('Earning Not Found')),
        ],
      ),
    );
  }
}
