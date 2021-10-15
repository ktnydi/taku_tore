import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({
    this.minWidth = double.infinity,
    this.height = 50,
    this.child,
    this.color,
    this.disabledColor = Colors.black12,
    this.textColor,
    this.disabledTextColor,
    this.focusColor,
    this.highlightColor,
    this.splashColor,
    this.side = BorderSide.none,
    this.onPressed,
  });

  final double minWidth;
  final double height;
  final Widget child;
  final Color color;
  final Color disabledColor;
  final Color textColor;
  final Color disabledTextColor;
  final Color focusColor;
  final Color highlightColor;
  final Color splashColor;
  final BorderSide side;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: minWidth,
      height: height,
      child: TextButton(
        child: child,
        style: TextButton.styleFrom(
          primary: textColor,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: side,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
