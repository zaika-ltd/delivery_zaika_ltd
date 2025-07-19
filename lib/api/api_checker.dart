import 'package:stackfood_multivendor_driver/feature/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor_driver/feature/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor_driver/helper/route_helper.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';

class ApiChecker {
  static final Map<String, String> errors = {};

  static void checkApi(Response response) {
    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      Get.find<ProfileController>().stopLocationRecord();
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }
    else if(response.statusCode == 403){
      if(response.body != null && response.body['errors'] != null) {
        List errorFromApi = response.body['errors'] ?? [];
        errors.clear();
        for (var error in errorFromApi) {
          errors[error['code']] = error['message'];
        }
        response.body['errors'].forEach((key, value) {
          errors[key] = value[0];
        });
      }
    }
    else {
      showCustomSnackBar(response.statusText);
    }
  }
}