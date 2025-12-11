import 'package:flutter/material.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    // Default values set karna agar fields null hon (Null Safety Check: ?? )
    final bool _isObscure = isObscure ?? false;
    final bool _enabled = enabled ?? true;
    final Color _backgroundColor = backgroundColor ?? const Color(0XffD9D9D9);
    final double _borderRadius = borderRadius ?? 0.0;
    final double _verticalPadding = verticalPadding ?? 18.0;
    final double _horizontalPadding = horizontalPadding ?? 15.0;
    final TextAlign _textAlign = textAlign ?? TextAlign.center;
    // --- InputDecoration ---
    final inputDecoration = InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        fontFamily: 'Akshar',
        color: Color(0Xff8B8B8B),
        fontSize: 35.0,
        fontWeight: FontWeight.w500,
      ),

      // Borders ko remove karna
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,

      // Content Padding
      contentPadding: EdgeInsets.symmetric(
        vertical: _verticalPadding,
        horizontal: _horizontalPadding,
      ),

      isDense: true,
    );

    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),

      child: TextField(
        controller: controller,
        obscureText: _isObscure,
        keyboardType: keyboardType,
        enabled: _enabled,
        textAlign: _textAlign,
        decoration: inputDecoration,

        style: const TextStyle(
          color: Colors.black,
          fontSize: 35.0,
          fontFamily: 'Akshar',
        ),

        textCapitalization: TextCapitalization.characters,
      ),
    );
  }
}
