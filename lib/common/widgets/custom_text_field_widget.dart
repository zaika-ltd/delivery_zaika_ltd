import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/common/widgets/code_picker_widget.dart';
import 'package:stackfood_multivendor_driver/helper/responsive_helper.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';
import 'package:flutter/services.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String titleText;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final Function? onChanged;
  final Function? onSubmit;
  final bool isEnabled;
  final int maxLines;
  final TextCapitalization capitalization;
  final String? prefixImage;
  final IconData? prefixIcon;
  final double prefixSize;
  final TextAlign textAlign;
  final bool isAmount;
  final bool isNumber;
  final bool showTitle;
  final bool showBorder;
  final double iconSize;
  final bool divider;
  final bool isPhone;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final bool isRequired;
  final bool showLabelText;
  final String? labelText;
  final double? levelTextSize;
  final String? errorText;

  const CustomTextFieldWidget({
    super.key,
    this.titleText = 'Write something...',
    this.hintText = '',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSubmit,
    this.onChanged,
    this.prefixImage,
    this.prefixIcon,
    this.capitalization = TextCapitalization.none,
    this.isPassword = false,
    this.prefixSize = Dimensions.paddingSizeSmall,
    this.textAlign = TextAlign.start,
    this.isAmount = false,
    this.isNumber = false,
    this.showTitle = false,
    this.showBorder = true,
    this.iconSize = 18,
    this.divider = false,
    this.isPhone = false,
    this.countryDialCode,
    this.onCountryChanged,
    this.isRequired = false,
    this.showLabelText = true,
    this.labelText,
    this.levelTextSize,
    this.errorText
  });

  @override
  CustomTextFieldWidgetState createState() => CustomTextFieldWidgetState();
}

class CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {

  bool _obscureText = true;

  void onFocusChanged(){
    FocusScope.of(context).unfocus();
    FocusScope.of(Get.context!).requestFocus(widget.focusNode);
    widget.focusNode?.addListener(() {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      widget.showTitle ? Text(widget.titleText, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)) : const SizedBox(),
      SizedBox(height: widget.showTitle ? ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraSmall : 0),

      TextField(
        onTap: onFocusChanged,
        maxLines: widget.maxLines,
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: widget.textAlign,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
        textInputAction: widget.inputAction,
        keyboardType: widget.isAmount ? TextInputType.number : widget.inputType,
        cursorColor: Theme.of(context).primaryColor,
        textCapitalization: widget.capitalization,
        enabled: widget.isEnabled,
        autofocus: false,
        obscureText: widget.isPassword ? _obscureText : false,
        inputFormatters: widget.inputType == TextInputType.phone ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9]'))]
            : widget.isAmount ? [FilteringTextInputFormatter.allow(RegExp(r'\d'))] : widget.isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'\d'))] : null,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(style: widget.showBorder ? BorderStyle.solid : BorderStyle.none, width: 0.3, color: Theme.of(context).primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(style: widget.showBorder ? BorderStyle.solid : BorderStyle.none, width: 1, color: Theme.of(context).primaryColor),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(style: widget.showBorder ? BorderStyle.solid : BorderStyle.none, width: 0.3, color: Theme.of(context).primaryColor),
          ),
          isDense: true,
          hintText: widget.hintText.isEmpty ? widget.titleText : widget.hintText,
          errorText: widget.errorText,
          fillColor: Theme.of(context).cardColor,
          hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor.withValues(alpha: 0.7)),
          filled: true,
          labelStyle : widget.showLabelText ? robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor) : null,
          label: widget.showLabelText ? Text.rich(TextSpan(children: [
            TextSpan(text: widget.labelText ?? '', style: robotoRegular.copyWith(
              fontSize: widget.levelTextSize ?? Dimensions.fontSizeDefault,
              color: ((widget.focusNode?.hasFocus == true || widget.controller!.text.isNotEmpty ) &&  widget.isEnabled) ? Theme.of(context).textTheme.bodyLarge?.color :  Theme.of(context).hintColor.withValues(alpha: 0.7),
            )),
            if(widget.isRequired && widget.labelText != null)
              TextSpan(text : ' *', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeDefault)),
            // if(widget.isEnabled == false)
            //   TextSpan(text: widget.hideEnableText ? '' : widget.fromUpdateProfile ? ' (${'phone_number_can_not_be_edited'.tr})' : ' (${'non_changeable'.tr})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).colorScheme.error)),
          ])) : null,
          prefixIcon:  widget.isPhone ? SizedBox(width: 95, child: Row(children: [
            Container(
              width: 85,height: 50,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusSmall),
                  bottomLeft: Radius.circular(Dimensions.radiusSmall),
                ),
              ),
              margin: const EdgeInsets.only(right: 0),
              padding: const EdgeInsets.only(left: 5),
              child: Center(
                child: CodePickerWidget(
                  flagWidth: 25,
                  padding: EdgeInsets.zero,
                  onChanged: widget.onCountryChanged,
                  initialSelection: widget.countryDialCode,
                  favorite: [widget.countryDialCode!],
                  countryFilter: [widget.countryDialCode!],
                  enabled: false,
                  dialogBackgroundColor: Theme.of(context).cardColor,
                  textStyle: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
              ),
            ),

            Container(
              height: 20, width: 2,
              color: Theme.of(context).disabledColor,
            )
          ]),
          ) : widget.prefixImage != null && widget.prefixIcon == null ? Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.prefixSize),
            child: Image.asset(widget.prefixImage!, height: 20, width: 20),
          )  : widget.prefixImage == null && widget.prefixIcon != null ? Icon(widget.prefixIcon, size: widget.iconSize, color: widget.focusNode?.hasFocus == true ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor.withValues(alpha: 0.7)) : null,
          suffixIcon: widget.isPassword ? IconButton(
            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
            onPressed: _toggle,
          ) : null,
        ),
        onSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus)
            : widget.onSubmit != null ? widget.onSubmit!(text) : null,
        onChanged: widget.onChanged as void Function(String)?,
      ),

      widget.divider ? const Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge), child: Divider()) : const SizedBox(),

    ]);
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}