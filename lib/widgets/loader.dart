import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
        width: 50.0,
        height: 50.0,
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        )
    )
    );
  }
}
