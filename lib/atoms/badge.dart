import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final int counter;
  final Widget child;

  Badge({this.counter = 0, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      overflow: Overflow.visible,
      children: <Widget>[
        child,
        this.counter > 0
            ? Positioned(
                top: -5,
                right: -5,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 18,
                    minWidth: 18,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red,
                    ),
                    child: Center(
                      child: Text(
                        '${this.counter}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
