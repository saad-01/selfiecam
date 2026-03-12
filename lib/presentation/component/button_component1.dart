import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

// ------------------------------------------------------------------
// Reusable Widget: Custom Icon Button IconData (Experience Selection ke liye)
// ------------------------------------------------------------------

class CustomIconButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback? onPressed;
  final Color? color;
  final double? iconSize;
  final Color? iconColor;
  final double? containerPadding;
  final double? borderRadius;
  final TextStyle? textStyle;
  final double? containerWidth;
  final double? containerHeight;
  final double? iconLabelSpacing;

  const CustomIconButton({
    super.key,
    this.icon,
    this.label,
    this.onPressed,
    this.color,
    this.iconSize,
    this.iconColor,
    this.containerPadding,
    this.borderRadius,
    this.textStyle,
    this.containerWidth,
    this.containerHeight,
    this.iconLabelSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final IconData _icon = icon ?? Icons.help_outline;
    final Color _color = color ?? const Color(0xff008FC8);
    final double _iconSize = iconSize ?? 4.h;
    final Color _iconColor = iconColor ?? Colors.white;
    final double _containerPadding = containerPadding ?? 2.w;
    final double _borderRadius = borderRadius ?? 2.w;
    final double _iconLabelSpacing = iconLabelSpacing ?? 1.h;

    final double _containerWidth = containerWidth ?? 30.w;
    final double _containerHeight = containerHeight ?? 20.h;

    final TextStyle _defaultTextStyle = TextStyle(
      fontFamily: 'Bebas',
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
    final TextStyle _finalTextStyle = _defaultTextStyle.merge(textStyle);

    List<Widget> columnChildren = [];

    if (icon != null) {
      columnChildren.add(Icon(_icon, size: _iconSize, color: _iconColor));
    }

    if (label != null && label!.isNotEmpty) {
      if (icon != null) {
        columnChildren.add(SizedBox(height: _iconLabelSpacing));
      }

      columnChildren.add(Text(label!.toUpperCase(), style: _finalTextStyle, textAlign: TextAlign.center));
    }

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: _containerWidth,
        height: _containerHeight,
        padding: EdgeInsets.all(_containerPadding),
        decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(_borderRadius)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: columnChildren,
        ),
      ),
    );
  }
}
// ------------------------------------------------------------------
// Reusable Widget: Custom Icon Button Assets Path (Experience Selection ke liye)
// ------------------------------------------------------------------

class CustomIconButton1 extends StatelessWidget {
  final String icon;
  final String? label;
  final VoidCallback? onPressed;
  final Color? color;
  final double? iconSize;
  final Color? iconColor;
  final double? containerPadding;
  final double? borderRadius;
  final TextStyle? textStyle;
  final double? containerWidth;
  final double? containerHeight;
  final double? iconLabelSpacing;
  final String? font;
  final double? fontSize;

  const CustomIconButton1({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.color,
    this.iconSize,
    this.iconColor,
    this.containerPadding,
    this.borderRadius,
    this.textStyle,
    this.containerWidth,
    this.containerHeight,
    this.iconLabelSpacing,
    this.font,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color _color = color ?? const Color(0xff008FC8);
    final double _iconSize = iconSize ?? 8.h;
    final Color _iconColor = iconColor ?? Colors.white;
    final double _containerPadding = containerPadding ?? 2.w;
    final double _borderRadius = borderRadius ?? 2.w;
    final double _iconLabelSpacing = iconLabelSpacing ?? 1.h;

    final double _containerWidth = containerWidth ?? 18.w;
    final double _containerHeight = containerHeight ?? 20.h;

    // final TextStyle _defaultTextStyle = TextStyle(
    //   fontFamily: 'Bebas',
    //   fontSize: 18.sp,
    //   fontWeight: FontWeight.w600,
    //   color: iconColor ?? Colors.white,
    // );
    final TextStyle _defaultTextStyle = GoogleFonts.getFont(
      font ?? 'Bebas Neue',
      fontSize: fontSize?.sp ?? 18.sp,
      height: font == 'Bebas Neue' ? null : 0.9,
      fontWeight: FontWeight.w600,
      color: iconColor ?? Colors.white,
    );
    final TextStyle _finalTextStyle = _defaultTextStyle.merge(textStyle);

    List<Widget> columnChildren = [];

    columnChildren.add(
      SizedBox(
        height: _iconSize,
        width: _iconSize,
        child: Image.asset(icon, fit: BoxFit.contain, color: iconColor),
      ),
    );

    if (label != null && label!.isNotEmpty) {
      columnChildren.add(SizedBox(height: _iconLabelSpacing));
      columnChildren.add(Text(label!.toUpperCase(), style: _finalTextStyle, textAlign: TextAlign.center));
    }

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: _containerWidth,
        height: _containerHeight,
        padding: EdgeInsets.all(_containerPadding),
        decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(_borderRadius)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: columnChildren,
        ),
      ),
    );
  }
}
// ------------------------------------------------------------------
// Reusable Widget: Custom Icon Button Assets Path (Experience Selection ke liye)
// ------------------------------------------------------------------

class ApprovalButton extends StatelessWidget {
  final String text;
  final Color color;
  final String iconAssetPath;
  final VoidCallback onPressed;

  const ApprovalButton({
    super.key,
    required this.text,
    required this.color,
    required this.iconAssetPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.2.h)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconAssetPath, height: 6.h, width: 6.h, color: Colors.white),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: SizedBox(
                height: 6.h,
                child: const VerticalDivider(color: Colors.white, thickness: 1),
              ),
            ),
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Reusable Widget: Utility Button (Refresh, Test Bandwidth, etc. ke liye)
// ------------------------------------------------------------------
class CustomUtilityButton extends StatelessWidget {
  final String? text;
  final Color? color;
  final VoidCallback? onPressed;
  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;
  final double? horizontalPadding;
  final double? horizontalMargin;
  final int? flex;

  const CustomUtilityButton({
    super.key,
    this.text,
    this.onPressed,
    this.color,
    this.height,
    this.borderRadius,
    this.textStyle,
    this.horizontalPadding,
    this.horizontalMargin,
    this.flex,
  });

  @override
  Widget build(BuildContext context) {
    final String _text = text ?? 'BUTTON';
    final Color _color = color ?? const Color(0xFF00B09B);
    final VoidCallback? _onPressed = onPressed;
    final double _height = height ?? 10.h;
    final double _borderRadius = borderRadius ?? 2.w;
    final double _horizontalPadding = horizontalPadding ?? 4.w;
    final double _horizontalMargin = horizontalMargin ?? 0.5.w;
    final int _flex = flex ?? 1;

    final TextStyle _defaultTextStyle = TextStyle(
      fontFamily: 'Bebas',
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
    final TextStyle _finalTextStyle = _defaultTextStyle.merge(textStyle);

    return Expanded(
      flex: _flex,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _horizontalMargin),
        child: ElevatedButton(
          onPressed: _onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _color,
            minimumSize: Size.fromHeight(_height),
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
            elevation: 0,
          ),
          child: Text(_text.toUpperCase(), textAlign: TextAlign.center, style: _finalTextStyle),
        ),
      ),
    );
  }
}
