import 'package:BRT/widgets/utilityWidgets.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class IconContainer extends StatelessWidget {
  IconContainer({
    this.icon,
    this.title,
    this.value,
    this.groupValue,
    this.onChnaged,
  });
  final String icon;
  final String title;
  final dynamic value;
  final dynamic groupValue;
  final Function(String) onChnaged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: GestureDetector(
        onTap: () => onChnaged(title),
        child: SelectorTile(
            icon: icon,
            title: title,
            isSelected: groupValue == value,
            firstWidget: Container()
            //  buildRadio(),
            ),
      ),
    );
  }

  SizedBox buildRadio() {
    return SizedBox(
        width: 25,
        child: Radio(
          activeColor: BRTbrown,
          value: value,
          groupValue: groupValue,
          onChanged: (x) => onChnaged(x),
        ));
  }
}

class SelectorTile extends StatelessWidget {
  const SelectorTile(
      {Key key,
      @required this.icon,
      @required this.isSelected,
      @required this.title,
      this.firstWidget})
      : super(key: key);

  final String icon;
  final String title;
  final Widget firstWidget;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? BrtMediumBrown : BRTlightBrown,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(20),
          child: Center(
              child: Image.asset(
            assetsDirectory + icon,
            height: 80,
            width: 80,
            color: isSelected ? BrtWhite : null,
          )),
        ),
        widgetSeperator(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            firstWidget,
            Expanded(
                child: Text(
              title ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            )),
          ],
        ),
      ],
    );
  }
}

class BRTCheckBox extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;

  final Function(bool) onChanged;
  BRTCheckBox({this.icon, this.title, this.isSelected, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
     
      child: GestureDetector(
        onTap: () => onChanged(isSelected),
        child: SelectorTile(
            icon: icon,
            title: title,
            isSelected: isSelected,
            firstWidget: Container(
              height: 1,
              width: 1,
            )
            //  Checkbox(
            //   value: isSelected,
            //   onChanged: (x) => onChanged,
            // ),
            ),
      ),
    );
  }
}
