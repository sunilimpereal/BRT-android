import 'package:BRT/constants.dart';
import 'package:flutter/material.dart';

class TitleSubtitleView extends StatelessWidget {
  final String title;
  final String subtitle;
  final EdgeInsets padding;
  TitleSubtitleView({this.title, this.subtitle, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: BrtGray,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(child: Text(subtitle ?? "-")),
            ],
          )
        ],
      ),
    );
  }
}
