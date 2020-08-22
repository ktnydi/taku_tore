import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  Loading(this.isLoading);

  final bool isLoading;
  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return Container();
    }

    return Container(
      color: Colors.white.withOpacity(0.7),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
