import 'dart:async';
import 'dart:io';
import 'package:stackfood_multivendor_driver/app.dart';
import 'package:stackfood_multivendor_driver/feature/config/app_config.dart';

import 'package:stackfood_multivendor_driver/feature/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor_driver/helper/notification_helper.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  AppConfig.init(Environment.STAGING);
  // AppConstants.baseUrl = 'https://staging.zaika.ltd';
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, String>> languages = await di.init();

  // Staging Base URL

  if (GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAGJenQNd-KCVh4vaL4u8D0gRXfCQKYW2o', // Staging Key
        appId:
            '1:533169250177:android:1f5ac2231262204b5ed280', // Staging App ID
        messagingSenderId: '533169250177', // Staging Sender ID
        projectId: 'zaika-19c9b', // Staging Project ID
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (_) {}
  runApp(MyApp(languages: languages, body: body));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
