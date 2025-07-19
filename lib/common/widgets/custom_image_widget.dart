import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';
import 'package:flutter/cupertino.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;
  const CustomImageWidget({super.key, required this.image, this.height, this.width, this.fit, this.placeholder});

  @override
  Widget build(BuildContext context) {

    if (kDebugMode) {
      print('============>> $image');
    }

    return FadeInImage.assetNetwork(
      placeholder: Images.placeholder, height: height, width: width, fit: fit,
      image: image,
      imageErrorBuilder: (c, o, s) => Image.asset(
        placeholder != null ? placeholder! : Images.placeholder,
        height: height, width: width, fit: fit,
      ),
    );
  }
}