import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? actionWidget;
  const CustomAppBarWidget({super.key, required this.title, this.isBackButtonExist = true, this.onBackPressed, this.actionWidget});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: true,
      leading: isBackButtonExist ? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: Theme.of(context).textTheme.bodyLarge!.color,
        onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
      ) : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
      elevation: 2,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
          child: actionWidget ?? const SizedBox(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size(1170, GetPlatform.isDesktop ? 70 : 50);
}