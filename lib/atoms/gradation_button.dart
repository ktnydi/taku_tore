import 'package:flutter/material.dart';

class GradationButton extends StatelessWidget {
  GradationButton({
    this.child,
    this.gradient,
    this.height = 44,
    this.onPressed,
    this.textColor = Colors.white,
    this.width,
  })  : assert(child != null),
        assert(gradient != null);

  final Widget child;
  final Gradient gradient;
  final double height;
  final Function onPressed;
  final Color textColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        width: this.width,
        height: this.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: this.gradient,
        ),
        child: TextButton(
          child: this.child,
          style: TextButton.styleFrom(
            primary: this.textColor,
            padding: EdgeInsets.zero,
          ),
          onPressed: this.onPressed,
        ),
      ),
    );
  }
}
