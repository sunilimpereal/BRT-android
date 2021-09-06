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
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      highlightColor: buttonColor.withOpacity(0.6),
      child: Ink(
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
