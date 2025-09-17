import 'package:stackfood_multivendor_driver/feature/language/domain/models/language_model.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';

class AppConstants {
  static const String appName = 'Zaika Delivery';
  static const double appVersion = 8.0;

  ///Flutter SDK 3.27.1

  static const String baseUrl = 'https://staging.zaika.ltd';
  static const String configUri = '/api/v1/config';
  static const String forgerPasswordUri =
      '/api/v1/auth/delivery-man/forgot-password';
  static const String verifyTokenUri = '/api/v1/auth/delivery-man/verify-token';
  static const String resetPasswordUri =
      '/api/v1/auth/delivery-man/reset-password';
  static const String loginUri = '/api/v1/auth/delivery-man/login';
  static const String tokenUri = '/api/v1/delivery-man/update-fcm-token';
  static const String currentOrdersUri =
      '/api/v1/delivery-man/current-orders?token=';
  static const String allOrdersUri = '/api/v1/delivery-man/all-orders';
  static const String latestOrdersUri =
      '/api/v1/delivery-man/latest-orders?token=';
  static const String recordLocationUri =
      '/api/v1/delivery-man/record-location-data';
  static const String profileUri = '/api/v1/delivery-man/profile?token=';
  static const String updateOrderStatusUri =
      '/api/v1/delivery-man/update-order-status';
  static const String updatePaymentStatusUri =
      '/api/v1/delivery-man/update-payment-status';
  static const String orderDetailsUri =
      '/api/v1/delivery-man/order-details?token=';
  static const String acceptOrderUri = '/api/v1/delivery-man/accept-order';
  static const String activeStatusUri =
      '/api/v1/delivery-man/update-active-status';
  static const String updateProfileUri = '/api/v1/delivery-man/update-profile';
  static const String notificationUri =
      '/api/v1/delivery-man/notifications?token=';
  static const String driverRemove =
      '/api/v1/delivery-man/remove-account?token=';
  static const String currentOrderUri = '/api/v1/delivery-man/order?token=';
  static const String dmRegisterUri = '/api/v1/auth/delivery-man/store';
  static const String zoneListUri = '/api/v1/zone/list';
  static const String zoneUri = '/api/v1/config/get-zone-id';
  static const String orderCancellationUri =
      '/api/v1/customer/order/cancellation-reasons';
  static const String vehiclesUri = '/api/v1/get-vehicles';
  static const String shiftUri = '/api/v1/delivery-man/dm-shift?token=';
  static const String deliveredOrderNotificationUri =
      '/api/v1/delivery-man/send-order-otp';
  static const String makeCollectedCashPaymentUri =
      '/api/v1/delivery-man/make-collected-cash-payment';
  static const String makeWalletAdjustmentUri =
      '/api/v1/delivery-man/make-wallet-adjustment';
  static const String walletPaymentListUri =
      '/api/v1/delivery-man/wallet-payment-list';
  static const String originalDeliveryCharges =
      '/api/v1/delivery-man/original-delivery-charge-list';
  static const String addWithdrawMethodUri =
      '/api/v1/delivery-man/withdraw-method/store';
  static const String disbursementMethodListUri =
      '/api/v1/delivery-man/withdraw-method/list';
  static const String makeDefaultDisbursementMethodUri =
      '/api/v1/delivery-man/withdraw-method/make-default';
  static const String deleteDisbursementMethodUri =
      '/api/v1/delivery-man/withdraw-method/delete';
  static const String getDisbursementReportUri =
      '/api/v1/delivery-man/get-disbursement-report';
  static const String withdrawRequestMethodUri =
      '/api/v1/delivery-man/get-withdraw-method-list';
  static const String firebaseAuthVerify =
      '/api/v1/auth/delivery-man/firebase-verify-token';

  //chat url
  static const String getConversationListUri =
      '/api/v1/delivery-man/message/list';
  static const String getMessageListUri =
      '/api/v1/delivery-man/message/details';
  static const String sendMessageUri = '/api/v1/delivery-man/message/send';
  static const String searchConversationListUri =
      '/api/v1/delivery-man/message/search-list';

  // Shared Key
  static const String theme = 'theme';
  static const String token = 'stackfood_multivendor_driver_token';
  static const String countryCode = 'country_code';
  static const String languageCode = 'language_code';
  static const String userPassword = 'user_password';
  static const String userAddress = 'user_address';
  static const String userNumber = 'user_number';
  static const String userCountryCode = 'user_country_code';
  static const String notification = 'notification';
  static const String notificationCount = 'notification_count';
  static const String ignoreList = 'ignore_list';
  static const String topic = 'all_zone_delivery_man';
  static const String zoneTopic = 'zone_topic';
  static const String localizationKey = 'X-localization';
  static const String zoneId = 'zoneId';
  static const String langIntro = 'language_intro';
  static const String maintenanceModeTopic = 'maintenance_mode_deliveryman_app';

  static List<LanguageModel> languages = [
    LanguageModel(
        imageUrl: Images.english,
        languageName: 'English',
        countryCode: 'US',
        languageCode: 'en'),
    // LanguageModel(imageUrl: Images.arabic, languageName: 'Arabic', countryCode: 'SA', languageCode: 'ar'),
    // LanguageModel(imageUrl: Images.spanish, languageName: 'Spanish', countryCode: 'ES', languageCode: 'es'),
    // LanguageModel(imageUrl: Images.bengali, languageName: 'Bengali', countryCode: 'BN', languageCode: 'bn'),
  ];

  static const double maxLimitOfFileSentINConversation = 25;
  static const double maxLimitOfTotalFileSent = 5;
  static const double maxSizeOfASingleFile = 10;
  static const double maxImageSend = 10;

  static const double limitOfPickedVideoSizeInMB = 50;
}
