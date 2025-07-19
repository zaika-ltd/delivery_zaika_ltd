import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor_driver/feature/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor_driver/feature/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor_driver/feature/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_driver/feature/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor_driver/feature/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor_driver/feature/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor_driver/feature/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor_driver/feature/order/widgets/camera_button_sheet_widget.dart';
import 'package:stackfood_multivendor_driver/feature/order/widgets/cancellation_dialogue_widget.dart';
import 'package:stackfood_multivendor_driver/feature/order/widgets/collect_money_delivery_sheet_widget.dart';
import 'package:stackfood_multivendor_driver/feature/order/widgets/dialogue_image_widget.dart';
import 'package:stackfood_multivendor_driver/feature/order/widgets/info_card_widget.dart';
import 'package:stackfood_multivendor_driver/feature/order/widgets/order_product_widget.dart';
import 'package:stackfood_multivendor_driver/feature/order/widgets/slider_button_widget.dart';
import 'package:stackfood_multivendor_driver/feature/order/widgets/verify_delivery_sheet_widget.dart';
import 'package:stackfood_multivendor_driver/feature/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor_driver/helper/date_converter_helper.dart';
import 'package:stackfood_multivendor_driver/helper/price_converter_helper.dart';
import 'package:stackfood_multivendor_driver/helper/responsive_helper.dart';
import 'package:stackfood_multivendor_driver/helper/route_helper.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';
import 'package:stackfood_multivendor_driver/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool? isRunningOrder;
  final int? orderIndex;
  final bool fromNotification;
  const OrderDetailsScreen({super.key, required this.orderId, required this.isRunningOrder, required this.orderIndex, this.fromNotification = false});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {

  Timer? _timer;
  int? orderPosition;

  void _startApiCalling(){
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getOrderWithId(Get.find<OrderController>().orderModel!.id);
    });
  }

  Future<void> _loadData() async {
    Get.find<OrderController>().pickPrescriptionImage(isRemove: true, isCamera: false);
    if(Get.find<OrderController>().showDeliveryImageField){
      Get.find<OrderController>().changeDeliveryImageStatus(isUpdate: false);
    }
    if(widget.orderIndex == null){
      await Get.find<OrderController>().getCurrentOrders();
      for(int index=0; index<Get.find<OrderController>().currentOrderList!.length; index++) {
        if(Get.find<OrderController>().currentOrderList![index].id == widget.orderId){
          orderPosition = index;
          break;
        }
      }
    }
    Get.find<OrderController>().getOrderWithId(widget.orderId);
    Get.find<OrderController>().getOrderDetails(widget.orderId);
  }

  @override
  void initState() {
    super.initState();

    orderPosition = widget.orderIndex;

    _loadData();
    _startApiCalling();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
  @override
  Widget build(BuildContext context) {

    bool? cancelPermission = Get.find<SplashController>().configModel!.canceledByDeliveryman;
    bool selfDelivery = Get.find<ProfileController>().profileModel!.type != 'zone_wise';

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,

        appBar: CustomAppBarWidget(title: 'order_details'.tr, onBackPressed: () {
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }else {
            Get.back();
          }
        }),
        body: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: GetBuilder<OrderController>(builder: (orderController) {

            OrderModel? controllerOrderModel = orderController.orderModel;

            bool restConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel != 'deliveryman';

            late bool showBottomView;
            late bool showSlider;
            bool showDeliveryConfirmImage = orderController.showDeliveryImageField && Get.find<SplashController>().configModel!.dmPictureUploadStatus!;

            double? deliveryCharge = 0;
            double itemsPrice = 0;
            double? discount = 0;
            double? couponDiscount = 0;
            double? dmTips = 0;
            double? tax = 0;
            bool? taxIncluded = false;
            double addOns = 0;
            double additionalCharge = 0;
            double extraPackagingAmount = 0;
            double referrerBonusAmount = 0;
            OrderModel? order = controllerOrderModel;

            if(order != null && orderController.orderDetailsModel != null ) {

              if(order.orderType == 'delivery') {
                deliveryCharge = order.deliveryCharge;
                dmTips = order.dmTips;
              }
              discount = order.restaurantDiscountAmount;
              tax = order.totalTaxAmount;
              taxIncluded = order.taxStatus;
              couponDiscount = order.couponDiscountAmount;
              additionalCharge = order.additionalCharge!;
              extraPackagingAmount = order.extraPackagingAmount!;
              referrerBonusAmount = order.referrerBonusAmount!;
              for(OrderDetailsModel orderDetails in orderController.orderDetailsModel!) {
                for(AddOn addOn in orderDetails.addOns!) {
                  addOns = addOns + (addOn.price! * addOn.quantity!);
                }
                itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
              }
            }
            double subTotal = itemsPrice + addOns;
            double total = itemsPrice + addOns - discount! + (taxIncluded! ? 0 : tax!) + deliveryCharge! - couponDiscount! + dmTips! + additionalCharge + extraPackagingAmount - referrerBonusAmount;

            if(controllerOrderModel != null){
              showBottomView = controllerOrderModel.orderStatus == 'accepted' || controllerOrderModel.orderStatus == 'confirmed'
                  || controllerOrderModel.orderStatus == 'processing' || controllerOrderModel.orderStatus == 'handover'
                  || controllerOrderModel.orderStatus == 'picked_up' || (widget.isRunningOrder ?? true);
              showSlider = (controllerOrderModel.paymentMethod == 'cash_on_delivery' && controllerOrderModel.orderStatus == 'accepted' && !restConfModel && !selfDelivery)
                  || controllerOrderModel.orderStatus == 'handover' || controllerOrderModel.orderStatus == 'picked_up';
            }

            return (orderController.orderDetailsModel != null && controllerOrderModel != null && order != null) ? Column(children: [

              Expanded(child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(children: [

                  DateConverter.isBeforeTime(controllerOrderModel.scheduleAt) ? (controllerOrderModel.orderStatus != 'delivered'
                  && controllerOrderModel.orderStatus != 'failed'&& controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refund_requested'
                  && controllerOrderModel.orderStatus != 'refunded' && controllerOrderModel.orderStatus != 'refund_request_canceled') ? Column(children: [

                    ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(Images.animateDeliveryMan, fit: BoxFit.contain)),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Text('food_need_to_deliver_within'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Center(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [

                        Text(
                          DateConverter.differenceInMinute(controllerOrderModel.restaurantDeliveryTime, controllerOrderModel.createdAt, controllerOrderModel.processingTime, controllerOrderModel.scheduleAt) < 5 ? '1 - 5'
                              : '${DateConverter.differenceInMinute(controllerOrderModel.restaurantDeliveryTime, controllerOrderModel.createdAt, controllerOrderModel.processingTime, controllerOrderModel.scheduleAt)-5} '
                              '- ${DateConverter.differenceInMinute(controllerOrderModel.restaurantDeliveryTime, controllerOrderModel.createdAt, controllerOrderModel.processingTime, controllerOrderModel.scheduleAt)}',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text('min'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),

                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  ]) : const SizedBox() : const SizedBox(),

                  Row(children: [

                    Text('${'order_id'.tr}:', style: robotoRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(controllerOrderModel.id.toString(), style: robotoMedium),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    const Expanded(child: SizedBox()),

                    Container(
                      height: 7, width: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (controllerOrderModel.orderStatus == 'failed' || controllerOrderModel.orderStatus == 'canceled' || controllerOrderModel.orderStatus == 'refund_request_canceled')
                        ? Colors.red : controllerOrderModel.orderStatus == 'refund_requested' ? Colors.yellow : Colors.green,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(
                      controllerOrderModel.orderStatus!.tr,
                      style: robotoRegular,
                    ),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  InfoCardWidget(
                    title: 'restaurant_details'.tr, addressModel: DeliveryAddress(address: controllerOrderModel.restaurantAddress),
                    image: '${controllerOrderModel.restaurantLogoFullUrl}',
                    name: controllerOrderModel.restaurantName, phone: controllerOrderModel.restaurantPhone,
                    latitude: controllerOrderModel.restaurantLat, longitude: controllerOrderModel.restaurantLng,
                    showButton: (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed' && controllerOrderModel.orderStatus != 'canceled'),
                    orderModel: controllerOrderModel,
                    messageOnTap: () async {
                      if(controllerOrderModel.restaurantModel != 'commission' && controllerOrderModel.chatPermission == 0){
                        showCustomSnackBar('restaurant_have_no_chat_permission'.tr);
                      }else{
                        _timer?.cancel();
                        await Get.toNamed(RouteHelper.getChatRoute(
                          notificationBody: NotificationBodyModel(
                            orderId: controllerOrderModel.id, vendorId: controllerOrderModel.vendorId,
                          ),
                          user: User(
                            id: controllerOrderModel.vendorId, fName: controllerOrderModel.restaurantName,
                            imageFullUrl: controllerOrderModel.restaurantLogoFullUrl,
                          ),
                        ));
                        _startApiCalling();
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  InfoCardWidget(
                    title: 'customer_contact_details'.tr, addressModel: controllerOrderModel.deliveryAddress, isDelivery: true,
                    image: controllerOrderModel.customer != null ? '${controllerOrderModel.customer!.imageFullUrl}' : '',
                    name: controllerOrderModel.deliveryAddress!.contactPersonName, phone: controllerOrderModel.deliveryAddress!.contactPersonNumber,
                    latitude: controllerOrderModel.deliveryAddress!.latitude, longitude: controllerOrderModel.deliveryAddress!.longitude,
                    showButton: (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed' && controllerOrderModel.orderStatus != 'canceled'),
                    orderModel: controllerOrderModel,
                    messageOnTap: () async {
                      if(controllerOrderModel.customer != null){
                        _timer?.cancel();
                        await Get.toNamed(RouteHelper.getChatRoute(
                          notificationBody: NotificationBodyModel(
                            orderId: controllerOrderModel.id, customerId: controllerOrderModel.customer!.id,
                          ),
                          user: User(
                            id: controllerOrderModel.customer!.id, fName: controllerOrderModel.customer!.fName,
                            lName: controllerOrderModel.customer!.lName, imageFullUrl: controllerOrderModel.customer!.imageFullUrl,
                          ),
                        ));
                        _startApiCalling();
                      }else{
                        showCustomSnackBar('customer_not_found'.tr);
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [

                        Text('${'item'.tr}:', style: robotoRegular),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text(
                          orderController.orderDetailsModel!.length.toString(),
                          style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                        ),
                        const Expanded(child: SizedBox()),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            controllerOrderModel.paymentMethod == 'cash_on_delivery' ? 'cod'.tr : controllerOrderModel.paymentMethod == 'wallet'
                                ? 'wallet_payment'.tr : 'digitally_paid'.tr,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                          ),
                        ),

                      ]),
                    ),
                    const Divider(height: Dimensions.paddingSizeLarge),

                    (controllerOrderModel.cutlery != null) ? Column(children: [

                      Row(children: [

                        Text('${'cutlery'.tr}: ', style: robotoRegular),
                        const Expanded(child: SizedBox()),

                        Text(
                          controllerOrderModel.cutlery! ? 'yes'.tr : 'no'.tr,
                          style: robotoRegular,
                        ),

                      ]),

                      const Divider(height: Dimensions.paddingSizeLarge),

                    ]) : const SizedBox(),

                    controllerOrderModel.unavailableItemNote != null ? Column(children: [

                      Row(children: [

                        Text('${'unavailable_item_note'.tr}: ', style: robotoMedium),

                        Text(
                          controllerOrderModel.unavailableItemNote!.tr,
                          style: robotoRegular,
                        ),

                      ]),

                      const Divider(height: Dimensions.paddingSizeLarge),

                    ]) : const SizedBox(),

                    controllerOrderModel.deliveryInstruction != null ? Column(children: [

                      Row(children: [

                        Text('${'delivery_instruction'.tr}: ', style: robotoMedium),

                        Text(
                          controllerOrderModel.deliveryInstruction!.tr,
                          style: robotoRegular,
                        ),

                      ]),

                      const Divider(height: Dimensions.paddingSizeLarge),

                    ]) : const SizedBox(),
                    SizedBox(height: controllerOrderModel.deliveryInstruction != null ? Dimensions.paddingSizeSmall : 0),

                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderController.orderDetailsModel!.length,
                      itemBuilder: (context, index) {
                        return OrderProductWidgetWidget(order: controllerOrderModel, orderDetails: orderController.orderDetailsModel![index]);
                      },
                    ),

                    (controllerOrderModel.orderNote  != null && controllerOrderModel.orderNote!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('additional_note'.tr, style: robotoRegular),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        width: 1170,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 1, color: Theme.of(context).disabledColor),
                        ),
                        child: Text(
                          controllerOrderModel.orderNote!.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                    ]) : const SizedBox(),

                    (controllerOrderModel.orderStatus == 'delivered' && controllerOrderModel.orderProofFullUrl != null
                    && controllerOrderModel.orderProofFullUrl!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('order_proof'.tr, style: robotoRegular),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1.5,
                          crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 5,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controllerOrderModel.orderProofFullUrl!.length,
                        itemBuilder: (BuildContext context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => openDialog(context, controllerOrderModel.orderProofFullUrl![index]),
                              child: Center(child: ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                child: CustomImageWidget(
                                  image: controllerOrderModel.orderProofFullUrl![index],
                                  width: 100, height: 100,
                                ),
                              )),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                    ]) : const SizedBox(),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('item_price'.tr, style: robotoRegular),
                      Text(PriceConverter.convertPrice(itemsPrice), style: robotoRegular, textDirection: TextDirection.ltr),
                    ]),
                    const SizedBox(height: 10),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('addons'.tr, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(addOns)}', style: robotoRegular, textDirection: TextDirection.ltr,),
                    ]),

                    Divider(thickness: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${'subtotal'.tr} ${taxIncluded ? '(${'tax_included'.tr})' : ''}', style: robotoMedium),
                      Text(PriceConverter.convertPrice(subTotal), style: robotoMedium, textDirection: TextDirection.ltr),
                    ]),
                    const SizedBox(height: 10),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('discount'.tr, style: robotoRegular),
                      Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular, textDirection: TextDirection.ltr),
                    ]),
                    const SizedBox(height: 10),

                    couponDiscount > 0 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('coupon_discount'.tr, style: robotoRegular),
                      Text(
                        '(-) ${PriceConverter.convertPrice(couponDiscount)}',
                        style: robotoRegular, textDirection: TextDirection.ltr,
                      ),
                    ]) : const SizedBox(),
                    SizedBox(height: couponDiscount > 0 ? 10 : 0),

                    (referrerBonusAmount > 0) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('referral_discount'.tr, style: robotoRegular),
                      Text('(-) ${PriceConverter.convertPrice(referrerBonusAmount)}', style: robotoRegular, textDirection: TextDirection.ltr),
                    ]) : const SizedBox(),
                    SizedBox(height: referrerBonusAmount > 0 ? 10 : 0),

                    !taxIncluded ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('vat_tax'.tr, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(tax)}', style: robotoRegular, textDirection: TextDirection.ltr),
                    ]) : const SizedBox(),
                    SizedBox(height: taxIncluded ? 0 : 10),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('delivery_man_tips'.tr, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(dmTips)}', style: robotoRegular, textDirection: TextDirection.ltr),
                    ]),
                    const SizedBox(height: 10),

                    (extraPackagingAmount > 0) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('extra_packaging'.tr, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(extraPackagingAmount)}', style: robotoRegular, textDirection: TextDirection.ltr),
                    ]) : const SizedBox(),
                    SizedBox(height: extraPackagingAmount > 0 ? 10 : 0),

                    (order.additionalCharge != null && order.additionalCharge! > 0) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(Get.find<SplashController>().configModel!.additionalChargeName!, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(order.additionalCharge)}', style: robotoRegular, textDirection: TextDirection.ltr),
                    ]) : const SizedBox(),
                    (order.additionalCharge != null && order.additionalCharge! > 0) ? const SizedBox(height: 10) : const SizedBox(),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('delivery_fee'.tr, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(deliveryCharge)}', style: robotoRegular, textDirection: TextDirection.ltr),
                    ]),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Divider(thickness: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
                    ),

                    order.paymentMethod == 'partial_payment' ? DottedBorder(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1,
                      strokeCap: StrokeCap.butt,
                      dashPattern: const [8, 5],
                      padding: const EdgeInsets.all(0),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(Dimensions.radiusDefault),
                      child: Ink(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        color: restConfModel ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.transparent,
                        child: Column(children: [

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('total_amount'.tr, style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                            )),
                            Text(
                              PriceConverter.convertPrice(total),
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            ),
                          ]),
                          const SizedBox(height: 10),

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('paid_by_wallet'.tr, style: restConfModel ? robotoMedium : robotoRegular),
                            Text(
                              PriceConverter.convertPrice(order.payments![0].amount),
                              style: restConfModel ? robotoMedium : robotoRegular,
                            ),
                          ]),
                          const SizedBox(height: 10),

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('${order.payments![1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments![1].paymentMethod?.toString().replaceAll('_', ' ')})', style: restConfModel ? robotoMedium : robotoRegular),
                            Text(
                              PriceConverter.convertPrice(order.payments![1].amount),
                              style: restConfModel ? robotoMedium : robotoRegular,
                            ),
                          ]),
                        ]),
                      ),
                    ) : const SizedBox(),

                    order.paymentMethod != 'partial_payment' ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('total_amount'.tr, style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                      )),
                      Text(
                        PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                      ),
                    ]) : const SizedBox(),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                ]),
              )),

              showDeliveryConfirmImage && controllerOrderModel.orderStatus != 'delivered' ? Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text('completed_after_delivery_picture'.tr, style: robotoRegular),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: orderController.pickedPrescriptions.length+1,
                      itemBuilder: (context, index) {

                        XFile? file = index == orderController.pickedPrescriptions.length ? null : orderController.pickedPrescriptions[index];

                        if(index < 5 && index == orderController.pickedPrescriptions.length) {
                          return InkWell(
                            onTap: () {
                              Get.bottomSheet(const CameraButtonSheetWidget());
                            },
                            child: Container(
                              height: 60, width: 60, alignment: Alignment.center, decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            ),
                              child:  Icon(Icons.camera_alt_sharp, color: Theme.of(context).primaryColor, size: 32),
                            ),
                          );
                        }

                        return file != null ? Container(
                          margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Stack(children: [

                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              child: GetPlatform.isWeb ? Image.network(
                                file.path, width: 60, height: 60, fit: BoxFit.cover,
                              ) : Image.file(
                                File(file.path), width: 60, height: 60, fit: BoxFit.cover,
                              ),
                            ),

                          ]),
                        ) : const SizedBox();
                      },
                    ),
                  ),

                ]),
              ) : const SizedBox(),

              SafeArea(
                child: showDeliveryConfirmImage && controllerOrderModel.orderStatus != 'delivered' ? CustomButtonWidget(
                  buttonText: 'complete_delivery'.tr,
                  onPressed: () {

                    if(Get.find<SplashController>().configModel!.orderDeliveryVerification!){
                      Get.find<NotificationController>().sendDeliveredNotification(controllerOrderModel.id);

                      Get.bottomSheet(VerifyDeliverySheetWidget(
                        orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                        cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                      ), isScrollControlled: true).then((isSuccess) {

                        if(isSuccess && controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery')){
                          Get.bottomSheet(CollectMoneyDeliverySheetWidget(
                            orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                            orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                            cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                          ), isScrollControlled: true, isDismissible: false);
                        }
                      });
                    } else{
                      Get.bottomSheet(CollectMoneyDeliverySheetWidget(
                        orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                        cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                      ), isScrollControlled: true);
                    }

                  },
                ) : showBottomView ? ((controllerOrderModel.orderStatus == 'accepted' && (controllerOrderModel.paymentMethod != 'cash_on_delivery' || restConfModel || selfDelivery))
                 || controllerOrderModel.orderStatus == 'processing' || controllerOrderModel.orderStatus == 'confirmed') ? Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    controllerOrderModel.orderStatus == 'processing' ? 'food_is_preparing'.tr : 'food_waiting_for_cook'.tr,
                    style: robotoMedium,
                  ),
                ) : showSlider ? (controllerOrderModel.paymentMethod == 'cash_on_delivery' && controllerOrderModel.orderStatus == 'accepted'
                && !restConfModel && cancelPermission! && !selfDelivery) ? Row(children: [
                  Expanded(child: TextButton(
                    onPressed: (){
                      orderController.setOrderCancelReason('');
                      Get.dialog(CancellationDialogueWidget(orderId: widget.orderId));
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(1170, 40), padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        side: BorderSide(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!),
                      ),
                    ),
                    child: Text('cancel'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: Dimensions.fontSizeLarge,
                    )),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: CustomButtonWidget(
                    buttonText: 'confirm'.tr, height: 40,
                    onPressed: () {
                      Get.dialog(ConfirmationDialogWidget(
                        icon: Images.warning, title: 'are_you_sure_to_confirm'.tr, description: 'you_want_to_confirm_this_order'.tr,
                        onYesPressed: () {
                          orderController.updateOrderStatus(controllerOrderModel.id, 'confirmed', back: true).then((success) {
                            if(success) {
                              Get.find<ProfileController>().getProfile();
                              Get.find<OrderController>().getCurrentOrders();
                            }
                          });
                        },
                      ), barrierDismissible: false);
                    },
                  )),
                ]) : SliderButtonWidget(
                  action: () {
                    if(controllerOrderModel.paymentMethod == 'cash_on_delivery' && controllerOrderModel.orderStatus == 'accepted' && !restConfModel && !selfDelivery) {
                      Get.dialog(ConfirmationDialogWidget(
                        icon: Images.warning, title: 'are_you_sure_to_confirm'.tr, description: 'you_want_to_confirm_this_order'.tr,
                        onYesPressed: () {
                          orderController.updateOrderStatus(controllerOrderModel.id, 'confirmed', back: true).then((success) {
                            if(success) {
                              Get.find<ProfileController>().getProfile();
                              Get.find<OrderController>().getCurrentOrders();
                            }
                          });
                        },
                      ), barrierDismissible: false);
                    }else if(controllerOrderModel.orderStatus == 'picked_up') {
                      if(Get.find<SplashController>().configModel!.orderDeliveryVerification!
                          || controllerOrderModel.paymentMethod == 'cash_on_delivery') {
                        orderController.changeDeliveryImageStatus();
                        if(Get.find<SplashController>().configModel!.dmPictureUploadStatus!) {
                          Get.dialog(const DialogImageWidget(), barrierDismissible: false);
                        } else {
                          if(Get.find<SplashController>().configModel!.orderDeliveryVerification!){
                            Get.find<NotificationController>().sendDeliveredNotification(controllerOrderModel.id);

                            Get.bottomSheet(VerifyDeliverySheetWidget(
                              orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                              orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                              cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                            ), isScrollControlled: true).then((isSuccess) {


                              if(isSuccess && controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery')){
                                Get.bottomSheet(CollectMoneyDeliverySheetWidget(
                                  orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                                  orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                                  cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                                ), isScrollControlled: true, isDismissible: false);
                              }
                            });
                          } else {
                            Get.bottomSheet(CollectMoneyDeliverySheetWidget(
                              orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                              orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                              cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                            ), isScrollControlled: true);
                          }
                        }

                      }else {
                        Get.find<OrderController>().updateOrderStatus(controllerOrderModel.id, 'delivered').then((success) {
                          if(success) {
                            Get.find<ProfileController>().getProfile();
                            Get.find<OrderController>().getCurrentOrders();
                          }
                        });
                      }
                    }else if(controllerOrderModel.orderStatus == 'handover') {
                      if(Get.find<ProfileController>().profileModel!.active == 1) {
                        Get.find<OrderController>().updateOrderStatus(controllerOrderModel.id, 'picked_up').then((success) {
                          if(success) {
                            Get.find<ProfileController>().getProfile();
                            Get.find<OrderController>().getCurrentOrders();
                          }
                        });
                      }else {
                        showCustomSnackBar('make_yourself_online_first'.tr);
                      }
                    }
                  },
                  label: Text(
                    (controllerOrderModel.paymentMethod == 'cash_on_delivery' && controllerOrderModel.orderStatus == 'accepted' && !restConfModel && !selfDelivery)
                        ? 'swipe_to_confirm_order'.tr : controllerOrderModel.orderStatus == 'picked_up' ? 'swipe_to_deliver_order'.tr
                        : controllerOrderModel.orderStatus == 'handover' ? 'swipe_to_pick_up_order'.tr : '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  ),
                  dismissThresholds: 0.5, dismissible: false, shimmer: true,
                  width: 1170, height: 60, buttonSize: 50, radius: 10,
                  icon: Center(child: Icon(
                    Get.find<LocalizationController>().isLtr ? Icons.double_arrow_sharp : Icons.keyboard_arrow_left,
                    color: Colors.white, size: 20.0,
                  )),
                  isLtr: Get.find<LocalizationController>().isLtr,
                  boxShadow: const BoxShadow(blurRadius: 0),
                  buttonColor: Theme.of(context).primaryColor,
                  backgroundColor: const Color(0xffF4F7FC),
                  baseColor: Theme.of(context).primaryColor,
                ) : const SizedBox() : const SizedBox(),
              ),

            ]) : const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
        child: Stack(children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: PhotoView(
              tightMode: true,
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ),

          Positioned(top: 0, right: 0, child: IconButton(
            splashRadius: 5,
            onPressed: () => Get.back(),
            icon: Icon(Icons.cancel, color: Theme.of(context).colorScheme.error),
          )),

        ]),
      );
    },
  );
}