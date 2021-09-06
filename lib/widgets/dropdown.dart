import 'package:BRT/constants.dart';
import 'package:BRT/widgets/utilityWidgets.dart';
import 'package:flutter/material.dart';

class BRTDropDownMenu extends StatefulWidget {
  final String selectedItem;
  final List<String> items;
  final Function onSelected;
  final EdgeInsetsGeometry padding;
  final String title;

  BRTDropDownMenu(
      {this.selectedItem,
      this.items,
      this.onSelected,
      this.title,
      this.padding});

  @override
  BRTDropDownMenuState createState() => BRTDropDownMenuState();
}

class BRTDropDownMenuState extends State<BRTDropDownMenu> {
  int selectedIndex = 0;
  String selectedItem;

  @override
  Widget build(BuildContext context) {
    selectedItem = widget.selectedItem;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.title.isEmpty
              ? Container()
              : Padding(
                  padding: widget.padding ??
                      const EdgeInsets.only(top: 16, bottom: 8),
                  child: BRTfieldhead(widget.title),
                ),
          ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonHideUnderline(
              child: Container(
                height: 44,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 0),
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: BRTlightBrown,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: DropdownButton<String>(
                      style: TextStyle(fontSize: 15, color: Colors.black),
                      iconEnabledColor: BRTbrown,
                      isExpanded: true,
                      value: selectedItem,
                      hint: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text(
                            selectedItem != null ? selectedItem : 'Select one'),
                      ),
                      items: widget.items.map((item) {
                        return DropdownMenuItem(
                            value: item,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Text(item),
                            ));
                      }).toList(),
                      onChanged: (item) {
                        setState(() {
                          selectedItem = item;
                          selectedIndex = widget.items.indexOf(item);
                          setState(() {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());

                            ///It will clear all focus of the textfield
                          });
                        });
                        widget.onSelected(item);
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
