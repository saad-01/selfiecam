import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ButtonComponent extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;

  final Color? backgroundColor;
  final double? borderRadius;
  final double? verticalPadding;
  final double? horizontalPadding;
  final TextStyle? textStyle;

  const ButtonComponent({
    super.key,
    this.text,
    this.onPressed,
    this.backgroundColor,
    this.borderRadius,
    this.verticalPadding,
    this.horizontalPadding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final String _text = text ?? 'BUTTON';
    final Color _backgroundColor = backgroundColor ?? const Color(0xffE6FF4B);
    final double _borderRadius = borderRadius ?? 3.w;
    final double _verticalPadding = verticalPadding ?? 2.h;
    final double _horizontalPadding = horizontalPadding ?? 4.w;

    final TextStyle _defaultTextStyle = TextStyle(
      fontFamily: 'Akshar',
      fontSize: 22.sp,
      color: Colors.black,
      fontWeight: FontWeight.w700,
    );

    final TextStyle finalTextStyle = _defaultTextStyle.merge(textStyle);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        padding: EdgeInsets.symmetric(
          vertical: _verticalPadding,
          horizontal: _horizontalPadding,
        ),
        elevation: 0,
        visualDensity: VisualDensity.compact,
        minimumSize: Size.fromHeight(_verticalPadding * 2 + 2.h),
      ),
      child: Text(_text.toUpperCase(), style: finalTextStyle),
    );
  }
}

/* class ButtonComponent extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;

  final Color? backgroundColor;
  final double? borderRadius;
  final double? verticalPadding;
  final double? horizontalPadding;
  final TextStyle? textStyle;

  const ButtonComponent({
    super.key,
    this.text,
    this.onPressed,
    this.backgroundColor,
    this.borderRadius,
    this.verticalPadding,
    this.horizontalPadding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final String _text = text ?? 'BUTTON';
    final Color _backgroundColor = backgroundColor ?? const Color(0xffE6FF4B);
    final double _borderRadius = borderRadius ?? 0.0;
    final double _verticalPadding = verticalPadding ?? 25.0;
    final double _horizontalPadding = horizontalPadding ?? 15.0;

    final TextStyle _defaultTextStyle = const TextStyle(
      fontFamily: 'Akshar',
      fontSize: 35.0,
      color: Colors.black,
      fontWeight: FontWeight.w700,
    );

    final TextStyle finalTextStyle = _defaultTextStyle.merge(textStyle);

    return ElevatedButton(
      onPressed: onPressed,

      style: ElevatedButton.styleFrom(
        backgroundColor: _backgroundColor,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),

        padding: EdgeInsets.symmetric(
          vertical: _verticalPadding,
          horizontal: _horizontalPadding,
        ),

        elevation: 0,
        visualDensity: VisualDensity.compact,

        minimumSize: Size.fromHeight(_verticalPadding * 2 + 5),
      ),

      child: Text(_text.toUpperCase(), style: finalTextStyle),
    );
  }
}
 */
