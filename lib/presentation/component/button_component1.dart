import 'package:flutter/material.dart';

// ------------------------------------------------------------------
// Reusable Widget: Custom Icon Button (Experience Selection ke liye)
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
    final double _iconSize = iconSize ?? 40.0;
    final Color _iconColor = iconColor ?? Colors.white;
    final double _containerPadding = containerPadding ?? 12.0;
    final double _borderRadius = borderRadius ?? 0.0;
    final double _iconLabelSpacing = iconLabelSpacing ?? 8.0;

    final double? _containerWidth = containerWidth ?? 130;
    final double? _containerHeight = containerHeight ?? 200;

    final TextStyle _defaultTextStyle = const TextStyle(
      fontFamily: 'Bebas',
      fontSize: 28,
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

      columnChildren.add(
        Text(
          label!.toUpperCase(),
          style: _finalTextStyle,
          textAlign: TextAlign.center,
        ),
      );
    }

    return InkWell(
      onTap: onPressed,

      child: Container(
        width: _containerWidth,
        height: _containerHeight,

        padding: EdgeInsets.all(_containerPadding),
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(_borderRadius),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: columnChildren,
        ),
      ),
    );
  }
}

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
  });

  @override
  Widget build(BuildContext context) {
    final Color _color = color ?? const Color(0xff008FC8);
    final double _iconSize = iconSize ?? 40.0;
    final Color _iconColor = iconColor ?? Colors.white;
    final double _containerPadding = containerPadding ?? 12.0;
    final double _borderRadius = borderRadius ?? 0.0;
    final double _iconLabelSpacing = iconLabelSpacing ?? 8.0;

    final double? _containerWidth = containerWidth ?? 130;
    final double? _containerHeight = containerHeight ?? 200;

    final TextStyle _defaultTextStyle = const TextStyle(
      fontFamily: 'Bebas',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
    final TextStyle _finalTextStyle = _defaultTextStyle.merge(textStyle);

    List<Widget> columnChildren = [];

    if (icon != null) {
      columnChildren.add(
        SizedBox(height: 80, width: 80, child: Image.asset(icon)),
      );
    }

    if (label != null && label!.isNotEmpty) {
      if (icon != null) {
        columnChildren.add(SizedBox(height: _iconLabelSpacing));
      }

      columnChildren.add(
        Text(
          label!.toUpperCase(),
          style: _finalTextStyle,
          textAlign: TextAlign.center,
        ),
      );
    }

    return InkWell(
      onTap: onPressed,

      child: Container(
        width: _containerWidth,
        height: _containerHeight,

        padding: EdgeInsets.all(_containerPadding),
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(_borderRadius),
        ),

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
    final double _height = height ?? 100.0;
    final double _borderRadius = borderRadius ?? 0.0;
    final double _horizontalPadding = horizontalPadding ?? 15.0;
    final double _horizontalMargin = horizontalMargin ?? 5.0;
    final int _flex = flex ?? 1;

    final TextStyle _defaultTextStyle = const TextStyle(
      fontFamily: 'Bebas',
      fontSize: 28,
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

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            elevation: 0,
          ),
          child: Text(
            _text.toUpperCase(),
            textAlign: TextAlign.center,
            style: _finalTextStyle,
          ),
        ),
      ),
    );
  }
}
