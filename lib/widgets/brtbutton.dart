import 'package:flutter/material.dart';

import '../constants.dart';

class BrtButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  final Color buttonColor;
  BrtButton(
      {@required this.title,
      @required this.onPressed,
      this.buttonColor = BRTbrown});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
        decoration: BoxDecoration(
            color: buttonColor, borderRadius: BorderRadius.circular(8)),
        child: Text(
          title ?? "",
          style: TextStyle(color: BrtWhite),
        ),
      ),
    );
  }
}
