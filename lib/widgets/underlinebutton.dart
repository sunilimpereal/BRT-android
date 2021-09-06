import 'package:flutter/material.dart';

import '../constants.dart';

class UnderLineButton extends StatelessWidget {
  UnderLineButton(this.title, {this.onTap});
  final String title;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        GestureDetector(
          onTap: onTap,
          child: Text(
            title,
            style: TextStyle(
                color: BRTbrown, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
