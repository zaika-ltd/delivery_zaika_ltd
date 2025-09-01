import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/services/auth_service_interface.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_driver/api/api_client.dart';
import 'package:stackfood_multivendor_driver/common/models/config_model.dart';
import 'package:stackfood_multivendor_driver/common/models/response_model.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/models/vehicle_model.dart';
import 'package:stackfood_multivendor_driver/helper/route_helper.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_snackbar_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;

  AuthController({required this.authServiceInterface});

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  XFile? _pickedImage;

  XFile? get pickedImage => _pickedImage;

  List<XFile> _pickedIdentities = [];

  List<XFile> get pickedIdentities => _pickedIdentities;
  final List<String> _identityTypeList = ['Pan Card', 'driving_license',];
  // final List<String> _identityTypeList = [ 'driving_license', 'Pan Card'];

  List<String> get identityTypeList => _identityTypeList;

  int _identityTypeIndex = 0;

  int get identityTypeIndex => _identityTypeIndex;

  final List<String?> _dmTypeList = ['freelancer', 'salary_based'];

  List<String?> get dmTypeList => _dmTypeList;

  int _dmTypeIndex = -1;

  int get dmTypeIndex => _dmTypeIndex;

  List<VehicleModel>? _vehicles;

  List<VehicleModel>? get vehicles => _vehicles;

  List<int?>? _vehicleIds;

  List<int?>? get vehicleIds => _vehicleIds;

  int? _vehicleIndex = 0;

  int? get vehicleIndex => _vehicleIndex;

  double _dmStatus = 0.4;

  double get dmStatus => _dmStatus;

  bool _showPassView = false;

  bool get showPassView => _showPassView;

  bool _lengthCheck = false;

  bool get lengthCheck => _lengthCheck;

  bool _numberCheck = false;

  bool get numberCheck => _numberCheck;

  bool _uppercaseCheck = false;

  bool get uppercaseCheck => _uppercaseCheck;

  bool _lowercaseCheck = false;

  bool get lowercaseCheck => _lowercaseCheck;

  bool _spatialCheck = false;

  bool get spatialCheck => _spatialCheck;

  List<Data>? _dataList;

  List<Data>? get dataList => _dataList;

  List<dynamic>? _additionalList;

  List<dynamic>? get additionalList => _additionalList;

  bool _isActiveRememberMe = false;

  bool get isActiveRememberMe => _isActiveRememberMe;

  void setJoinUsPageData({bool isUpdate = true}) {
    _dataList = authServiceInterface.processDataList(Get
        .find<SplashController>()
        .configModel!
        .deliverymanAdditionalJoinUsPageData);
    _additionalList = authServiceInterface.processAdditionalDataList(Get
        .find<SplashController>()
        .configModel!
        .deliverymanAdditionalJoinUsPageData);
    if (isUpdate) {
      update();
    }
  }

  void setAdditionalDate(int index, String date) {
    _additionalList![index] = date;
    update();
  }

  void setAdditionalCheckData(int index, int i, String date) {
    if (_additionalList![index][i] == date) {
      _additionalList![index][i] = 0;
    } else {
      _additionalList![index][i] = date;
    }
    update();
  }

  Future<void> pickFile(int index, MediaData mediaData) async {
    FilePickerResult? result = await authServiceInterface.picFile(mediaData);
    if (result != null) {
      _additionalList![index].add(result);
    }
    update();
  }

  void removeAdditionalFile(int index, int subIndex) {
    _additionalList![index].removeAt(subIndex);
    update();
  }

  void showHidePass({bool isUpdate = true}) {
    _showPassView = !_showPassView;
    if (isUpdate) {
      update();
    }
  }

  Future<ResponseModel> login(String phone, String password) async {
    _isLoading = true;
    update();
    Response response = await authServiceInterface.login(phone, password);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      authServiceInterface.saveUserToken(response);
      await authServiceInterface.updateToken();
      responseModel = ResponseModel(true, 'successful');
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authServiceInterface.clearSharedData();
  }

  void saveUserNumberAndPassword(String number, String password,
      String countryCode) {
    authServiceInterface.saveUserNumberAndPassword(
        number, password, countryCode);
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  void setDMTypeIndex(int? dmType, bool notify) {
    _dmTypeIndex = dmType!;
    if (notify) {
      update();
    }
  }

  void removeDmImage() {
    _pickedImage = null;
    update();
  }

  void setIdentityTypeIndex(String? identityType, bool notify) {
    int index0 = 0;
    for (int index = 0; index < _identityTypeList.length; index++) {
      if (_identityTypeList[index] == identityType) {
        index0 = index;
        break;
      }
    }
    _identityTypeIndex = index0;
    if (notify) {
      update();
    }
  }

  String camelToSentence(String text) {
    var result = text.replaceAll('_', " ");
    var finalResult = result[0].toUpperCase() + result.substring(1);
    return finalResult;
  }

  void pickDmImageForRegistration(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    } else {
      if (isLogo) {
        _pickedImage = await authServiceInterface.pickImageFromCamera();
      } else {
        XFile? pickedIdentities = await authServiceInterface
            .pickImageFromCamera();
        if (pickedIdentities != null) {
          _pickedIdentities.add(pickedIdentities);
        }
      }
      update();
    }
  }

    showImagePickerBottomSheet({int? index, MediaData? mediaData,required bool isAadhaar,}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Get.back();
                picImageFromGalleryCamera(isAadhaar,index: index , true);
                // Use the image
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Get.back();
                if(isAadhaar && index !=null && mediaData != null){

                  pickFile(index,mediaData);
                }else{
                picImageFromGalleryCamera(false, false);}

                // Use the image
              },
            ),
          ],
        ),
      ),
    );
  }

  void picImageFromGalleryCamera(bool isAadhaarCard,bool isCamera,{int? index })async {
    // _pickedIdentities = [];
    if (isAadhaarCard) {
     var pickedFile =  await authServiceInterface
          .pickImageFromGalleryCamera(isCamera);
    if (pickedFile != null && index != null) {
      final platformFile = PlatformFile(
        name: pickedFile.name,
        path: pickedFile.path,
        size: await pickedFile.length(),
      );
      final result = FilePickerResult([platformFile]);

      _additionalList![index].add(result);
    }
    } else {
      XFile? pickedIdentities = await authServiceInterface
          .pickImageFromGalleryCamera(isCamera);
      if (pickedIdentities != null) {
        _pickedIdentities.add(pickedIdentities);
      }
    }
    update();
  }
  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }

  Future<void> registerDeliveryMan(Map<String, String> data, List<FilePickerResult> additionalDocuments, List<String> inputTypeList) async {
    _isLoading = true;
    update();

    List<MultipartBody> multiParts = authServiceInterface.prepareMultiPartsBody(_pickedImage, _pickedIdentities);
    List<MultipartDocument> multiPartsDocuments = authServiceInterface.prepareMultipartDocuments(inputTypeList, additionalDocuments);

    bool isSuccess = await authServiceInterface.registerDeliveryMan(data, multiParts, multiPartsDocuments);
    if (isSuccess) {
      Get.offAllNamed(RouteHelper.getSignInRoute());
      showCustomSnackBar('delivery_man_registration_successful'.tr, isError: false);
    }
    _isLoading = false;
    update();
  }

  Future<void> getVehicleList() async {
    _vehicleIds = null;
    List<VehicleModel>? vehicles = await authServiceInterface.getVehicleList();
    if (vehicles != null) {
      _vehicles = [];
      _vehicles!.addAll(vehicles);
      _vehicleIds = authServiceInterface.vehicleIds(vehicles);
    }
    update();
  }

  void setVehicleIndex(int? index, bool notify) {
    _vehicleIndex = index;
    if(notify) {
      update();
    }
  }

  void validPassCheck(String pass, {bool isUpdate = true}) {
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if(pass.length > 7){
      _lengthCheck = true;
    }
    if(pass.contains(RegExp(r'[a-z]'))){
      _lowercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[A-Z]'))){
      _uppercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[ .!@#$&*~^%]'))){
      _spatialCheck = true;
    }
    if(pass.contains(RegExp(r'[\d+]'))){
      _numberCheck = true;
    }
    if(isUpdate) {
      update();
    }
  }

  void dmStatusChange(double value, {bool isUpdate = true}){
    _dmStatus = value;
    if(isUpdate) {
      update();
    }
  }

}