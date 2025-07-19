import 'package:stackfood_multivendor_driver/feature/auth/controllers/address_controller.dart';
import 'package:stackfood_multivendor_driver/feature/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor_driver/feature/order/screens/order_details_screen.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_driver/feature/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor_driver/feature/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor_driver/helper/date_converter_helper.dart';
import 'package:stackfood_multivendor_driver/helper/price_converter_helper.dart';
import 'package:stackfood_multivendor_driver/helper/route_helper.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';
import 'package:stackfood_multivendor_driver/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCardWidget extends StatelessWidget {
  final OrderModel orderModel;
  final OrderController orderController;
  final int index;
  final Function onTap;
  const LocationCardWidget({super.key, required this.orderModel, required this.orderController, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {

    double restaurantDistance = Get.find<AddressController>().getRestaurantDistance(
      LatLng(double.parse(orderModel.restaurantLat!), double.parse(orderModel.restaurantLng!)),
    );

    double restaurantToCustomerDistance = Get.find<AddressController>().getRestaurantDistance(
      LatLng(double.parse(orderModel.restaurantLat!), double.parse(orderModel.restaurantLng!)),
      customerLatLng: LatLng(double.parse(orderModel.deliveryAddress?.latitude??'0'), double.parse(orderModel.deliveryAddress?.longitude??'0')),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Text(
                  '${restaurantDistance > 1000 ? '1000+' : restaurantDistance.toStringAsFixed(2)} ${'km_aprox'.tr} ', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                'your_distance_from_restaurant'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
              ),

            ]),

            Text(
              '${DateConverter.timeDistanceInMin(orderModel.createdAt!)} ${'mins_ago'.tr}',
              style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
            ),

          ]),
        ),

        const Divider(),

        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Text(
                '${restaurantToCustomerDistance > 1000 ? '1000+' : restaurantToCustomerDistance.toStringAsFixed(2)} ${'km_aprox'.tr}', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(
              'from_customer_to_restaurant_distance'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
            ),

          ]),
        ),

        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusDefault)),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          margin: const EdgeInsets.all(0.2),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

            Expanded(
              child: Wrap(alignment: WrapAlignment.center, runAlignment: WrapAlignment.center, children: [

                (Get.find<SplashController>().configModel!.showDmEarning! && Get.find<ProfileController>().profileModel!.earnings == 1) ? Text(
                  PriceConverter.convertPrice(orderModel.originalDeliveryCharge! + orderModel.dmTips!),
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ) : const SizedBox(),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(
                  '(${orderModel.paymentMethod == 'cash_on_delivery' ? 'cod'.tr : 'digitally_paid'.tr})',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),

              ]),
            ),

            Expanded(
              child: Row(children: [

                Expanded(
                  child: TextButton(
                    onPressed: () => Get.dialog(ConfirmationDialogWidget(
                      icon: Images.warning, title: 'are_you_sure_to_ignore'.tr, description: 'you_want_to_ignore_this_order'.tr, onYesPressed: () {
                      orderController.ignoreOrder(index);
                      Get.back();
                      Get.back();
                      showCustomSnackBar('order_ignored'.tr, isError: false);
                    },
                    ), barrierDismissible: false),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(1170, 50), padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        side: BorderSide(width: 1, color: Theme.of(context).disabledColor),
                      ),
                    ),
                    child: Text('ignore'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: Dimensions.fontSizeLarge,
                    )),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: CustomButtonWidget(
                    height: 50,
                    radius: Dimensions.radiusDefault,
                    buttonText: 'accept'.tr,
                    onPressed: () => Get.dialog(ConfirmationDialogWidget(
                      icon: Images.warning, title: 'are_you_sure_to_accept'.tr, description: 'you_want_to_accept_this_order'.tr, onYesPressed: () {
                      orderController.acceptOrder(orderModel.id, index, orderModel).then((isSuccess) {
                        if(isSuccess) {
                          onTap();
                          orderModel.orderStatus = (orderModel.orderStatus == 'pending' || orderModel.orderStatus == 'confirmed') ? 'accepted' : orderModel.orderStatus;
                          Get.back();
                          Get.toNamed(
                            RouteHelper.getOrderDetailsRoute(orderModel.id),
                            arguments: OrderDetailsScreen(
                              orderId: orderModel.id, isRunningOrder: true, orderIndex: orderController.currentOrderList!.length-1,
                            ),
                          );
                        }else {
                          orderController.getLatestOrders();
                        }
                      });
                      },
                    ), barrierDismissible: false),
                  ),
                ),

              ]),
            ),

          ]),
        ),
      ]),
    );
  }
}