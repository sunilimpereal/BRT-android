import 'package:BRT/constants.dart';
import 'package:BRT/strings.dart';
import 'package:flutter/material.dart';

class BRTRadioButton extends StatefulWidget {
  final List<String> titles;
  final String selectedIndex;
  final Function onChecked;
  final Function onUnchecked;
  final List<String> icons;

  BRTRadioButton(this.titles, this.selectedIndex,
      {this.onChecked, this.onUnchecked, this.icons});
  @override
  _BRTRadioButtonState createState() => _BRTRadioButtonState();
}

class _BRTRadioButtonState extends State<BRTRadioButton> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.titles.length,
      itemBuilder: (_, index) {
        return Row(
          children: <Widget>[
            Container(
              child: Column(children: [
                widget.icons != null
                    ? Image.asset(assetsDirectory + "${widget.icons[index]}")
                    : Container(),
                Row(
                  children: [
                    Radio(
                        activeColor: Colors.black,
                        groupValue: widget.selectedIndex,
                        value: widget.titles[index],
                        onChanged: (value) {
                          if (value) {
                            widget.onChecked(index);
                          } else {
                            widget.onUnchecked(index);
                          }
                        }),
                    Text(
                      widget.titles[index],
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    )
                  ],
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}
