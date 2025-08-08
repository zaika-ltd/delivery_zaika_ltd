import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cash_in_hand_controller.dart';
import 'ear_tra_card.dart';
class TransactionWidget extends StatelessWidget {
  final CashInHandController cashInHandController;
  const TransactionWidget({super.key, required this.cashInHandController});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('Transactions'),
      child: Column(children: [
        cashInHandController.transactions == null
            ? const Center(
            child: CircularProgressIndicator()) // Show loader if loading
            : cashInHandController.transactions!.isNotEmpty
            ? ListView.builder(
          itemCount: cashInHandController.transactions!.length > 25
              ? 25
              : cashInHandController.transactions!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return EarningTransactionCard(

                amount: cashInHandController.transactions![index]
                    .amount ??
                    0,
                date:cashInHandController.transactions![index].paymentTime ??
                    "",
                orderId:'${'paid_via'.tr} ${cashInHandController
                    .transactions![index].method?.replaceAll('_', ' ').capitalize??''}'
                  );
          },
        )
            : Padding(
            padding: const EdgeInsets.only(top: 250),
            child: Text('no_transaction_found'.tr)),
      ]),
    );
  }
}
