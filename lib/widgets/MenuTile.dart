// This widget is specific to homepage

import 'package:BRT/widgets/iconcontainer.dart';
import 'package:BRT/widgets/secondarybutton.dart';
import 'package:BRT/widgets/utilityWidgets.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class MenuTile extends StatelessWidget {
  final String title, subtitle, buttonText;
  final Function onPressed;
  final String icon;

  MenuTile(
      {this.title, this.subtitle, this.buttonText, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            Container(
                height: 70,
                width: 90,
                decoration: BoxDecoration(
                    color: BRTlightBrown,
                    borderRadius: BorderRadius.circular(10)),
                child: Image.asset(icon,color: Colors.green,)),
            SizedBox(
              width: 10,
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title ?? "",
                style: TextStyle(color: Brtblack, fontWeight: FontWeight.w600),
              ),
              widgetSeperator(),
              Text(
                subtitle ?? "",
                style: TextStyle(color: BrtSubtitleColor),
              )
            ]),
          ],
        ),

        OutlinedButton(
          onPressed: onPressed,
            
           child: Text('$buttonText'))
        // BrtSecondaryButton(
        //   buttonText: buttonText,
        //   onPressed: onPressed,
        // )
      ]),
    );
  }
}
