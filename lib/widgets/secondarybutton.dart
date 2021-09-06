import 'package:flutter/material.dart';

import '../constants.dart';

class BrtSecondaryButton extends StatelessWidget {
  final String buttonText;
  final Function onPressed;
  final String leadingImageIcon;

  BrtSecondaryButton({this.buttonText, this.onPressed, this.leadingImageIcon});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leadingImageIcon != null
                ? Image.asset(leadingImageIcon)
                : Container(),
            Text(
              buttonText,
              style: TextStyle(color: BRTbrown),
            ),
          ],
        ),
      ),
    );
  }
}
