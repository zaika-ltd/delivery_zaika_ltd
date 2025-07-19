import 'package:stackfood_multivendor_driver/common/models/response_model.dart';
import 'package:stackfood_multivendor_driver/feature/profile/domain/models/profile_model.dart';

abstract class ForgotPasswordServiceInterface {
  Future<dynamic> changePassword(ProfileModel userInfoModel, String password);
  Future<dynamic> forgotPassword(String? phone);
  Future<dynamic> resetPassword(String? resetToken, String phone, String password, String confirmPassword);
  Future<dynamic> verifyToken(String? phone, String token);
  Future<ResponseModel> verifyFirebaseOtp({required String phoneNumber, required String session, required String otp});
}