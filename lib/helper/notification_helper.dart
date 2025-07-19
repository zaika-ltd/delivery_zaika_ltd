import 'dart:convert';
import 'dart:io';
import 'package:stackfood_multivendor_driver/feature/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor_driver/feature/dashboard/screens/dashboard_screen.dart';
import 'package:stackfood_multivendor_driver/feature/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor_driver/feature/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor_driver/feature/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_driver/helper/custom_print_helper.dart';
import 'package:stackfood_multivendor_driver/helper/route_helper.dart';
import 'package:stackfood_multivendor_driver/helper/user_type_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stackfood_multivendor_driver/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotificationHelper {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
    flutterLocalNotificationsPlugin.initialize(initializationsSettings, onDidReceiveNotificationResponse: (load) async{
      try{
        if(load.payload!.isNotEmpty){

          NotificationBodyModel payload = NotificationBodyModel.fromJson(jsonDecode(load.payload!));

          if(payload.notificationType == NotificationType.order || payload.notificationType == NotificationType.assign){
            Get.toNamed(RouteHelper.getOrderDetailsRoute(payload.orderId, fromNotification: true));
          }else if(payload.notificationType == NotificationType.order_request){
            customPrint('order requested------------');
            Get.toNamed(RouteHelper.getMainRoute('order-request'));
          }else if(payload.notificationType == NotificationType.message){
            Get.toNamed(RouteHelper.getChatRoute(notificationBody: payload, conversationId: payload.conversationId, fromNotification: true));
          }else if(payload.notificationType == NotificationType.block || payload.notificationType == NotificationType.unblock){
            Get.toNamed(RouteHelper.getSignInRoute());
          }else if(payload.notificationType == NotificationType.unassign){
            Get.to(const DashboardScreen(pageIndex: 1));
          }else{
            Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
          }

        }
      }catch(_){}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      customPrint("onMessage: ${message.data}");
      customPrint("onMessage message type:${message.data['type']}");

      if(message.data['type'] == 'maintenance'){
        Get.find<SplashController>().getConfigData();
      }

      if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.chatScreen)){
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1, type: Get.find<ChatController>().type);
          if(Get.find<ChatController>().messageModel!.conversation!.id.toString() == message.data['conversation_id'].toString()) {
            Get.find<ChatController>().getMessages(
              1, NotificationBodyModel(
              notificationType: NotificationType.message,
              customerId: message.data['sender_type'] == UserType.user.name ? 0 : null,
              vendorId: message.data['sender_type'] == UserType.vendor.name ? 0 : null,
            ),
              null, int.parse(message.data['conversation_id'].toString()),
            );
          }else {
            NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
          }
        }
      }else if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.conversationListScreen)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1, type: Get.find<ChatController>().type);
        }
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
      }else if(message.data['type'] == 'maintenance'){
      }else {
        String? type = message.data['type'];

        if (type != 'assign' && type != 'new_order' && type != 'order_request') {
          NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
          Get.find<OrderController>().getCurrentOrders();
          Get.find<OrderController>().getLatestOrders();
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      customPrint("onOpenApp: ${message.data}");
      customPrint("onOpenApp message type:${message.data['type']}");
      try{
        if(message.data.isNotEmpty){

          NotificationBodyModel notificationBody = convertNotification(message.data)!;

          if(notificationBody.notificationType == NotificationType.order || notificationBody.notificationType == NotificationType.assign){
            Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(message.data['order_id']), fromNotification: true));
          }else if(notificationBody.notificationType == NotificationType.order_request){
            Get.toNamed(RouteHelper.getMainRoute('order-request'));
          }else if(notificationBody.notificationType == NotificationType.message){
            Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationId: notificationBody.conversationId, fromNotification: true));
          }else if(notificationBody.notificationType == NotificationType.unassign){
            Get.to(const DashboardScreen(pageIndex: 1));
          }else{
            Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
          }
        }
      }catch (_) {}
    });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    if(!GetPlatform.isIOS) {
      String? title;
      String? body;
      String? image;
      NotificationBodyModel? notificationBody;

      title = message.data['title'];
      body = message.data['body'];
      notificationBody = convertNotification(message.data);

      image = (message.data['image'] != null && message.data['image'].isNotEmpty)
          ? message.data['image'].startsWith('http') ? message.data['image']
          : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;

      if(image != null && image.isNotEmpty) {
        try{
          await showBigPictureNotificationHiddenLargeIcon(title, body, notificationBody, image, fln);
        }catch(e) {
          await showBigTextNotification(title, body!, notificationBody, fln);
        }
      }else {
        await showBigTextNotification(title, body!, notificationBody, fln);
      }
    }
  }

  static Future<void> showTextNotification(String title, String body, NotificationBodyModel? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stackfood', 'stackfood_delivery name', playSound: true,
      importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigTextNotification(String? title, String body, NotificationBodyModel? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stackfood', 'stackfood_delivery name', importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, NotificationBodyModel? notificationBody, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stackfood', 'stackfood_delivery name',
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBodyModel? convertNotification(Map<String, dynamic> data){
    if(data['type'] == 'order_status' || data['type'] == 'assign') {
      return NotificationBodyModel(orderId: int.parse(data['order_id']), notificationType: NotificationType.order);
    }else if(data['type'] == 'message') {
      return NotificationBodyModel(
        conversationId: (data['conversation_id'] != null && data['conversation_id'].isNotEmpty) ? int.parse(data['conversation_id']) : null,
        notificationType: NotificationType.message,
        type: data['sender_type'] == UserType.user.name ? UserType.user.name : UserType.vendor.name,
      );
    }else if(data['type'] == 'order_request'){
      return NotificationBodyModel(notificationType: NotificationType.order_request);
    }else if(data['type'] == 'block'){
      return NotificationBodyModel(notificationType: NotificationType.block);
    }else if(data['type'] == 'unblock'){
      return NotificationBodyModel(notificationType: NotificationType.unblock);
    }else if(data['type'] == 'cash_collect'){
      return NotificationBodyModel(notificationType: NotificationType.general);
    }else if(data['type'] == 'unassign'){
      return NotificationBodyModel(notificationType: NotificationType.unassign);
    }else{
      return NotificationBodyModel(notificationType: NotificationType.general) ;
    }
  }

}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  customPrint("onBackground: ${message.data}");
}