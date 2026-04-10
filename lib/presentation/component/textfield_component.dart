import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TextfieldComponent extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool? isObscure;
  final TextInputType? keyboardType;
  final bool? enabled;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? verticalPadding;
  final double? horizontalPadding;
  final TextAlign? textAlign;
  final bool? isRequired;
  final void Function(String)? onChanged;

  const TextfieldComponent({
    super.key,
    this.hintText,
    this.controller,
    this.isObscure,
    this.keyboardType,
    this.enabled,
    this.backgroundColor,
    this.borderRadius,
    this.verticalPadding,
    this.horizontalPadding,
    this.textAlign,
    this.isRequired,
    this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    final bool _isObscure = isObscure ?? false;
    final bool _enabled = enabled ?? true;
    final Color _backgroundColor = backgroundColor ?? const Color(0XffD9D9D9);
    final double _borderRadius = borderRadius ?? 0.0;
    final double _verticalPadding = verticalPadding ?? 1.0.h;
    final double _horizontalPadding = horizontalPadding ?? 4.w;
    final TextAlign _textAlign = textAlign ?? TextAlign.center;

    final inputDecoration = InputDecoration(
      hint: RichText(
        textAlign: _textAlign,
        text: TextSpan(
          text: hintText?.toUpperCase(),
          style: TextStyle(fontFamily: 'Akshar', color: const Color(0Xff8B8B8B), fontSize: 22.sp, fontWeight: FontWeight.w500),
          children: isRequired != null && isRequired == true
              ? [
                  TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : [],
        ),
      ),
      // hintText: hintText?.toUpperCase(),
      // hintStyle: TextStyle(fontFamily: 'Akshar', color: const Color(0Xff8B8B8B), fontSize: 22.sp, fontWeight: FontWeight.w500),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,

      // isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: _verticalPadding, horizontal: _horizontalPadding),
    );

    return Container(
      decoration: BoxDecoration(color: _backgroundColor, borderRadius: BorderRadius.circular(_borderRadius)),
      child: TextField(
        controller: controller,
        obscureText: _isObscure,
        keyboardType: keyboardType,
        enabled: _enabled,
        onChanged: onChanged,
        textAlign: _textAlign,
        decoration: inputDecoration,
        style: TextStyle(color: Colors.black, fontSize: 22.sp, fontFamily: 'Akshar'),
      ),
    );
  }
}
