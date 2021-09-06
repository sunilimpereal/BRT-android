import 'package:BRT/widgets/dropdown.dart';
import 'package:BRT/widgets/utilityWidgets.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'brtFormfield.dart';

class TicketInformationSection extends StatefulWidget {
  const TicketInformationSection(
      {Key key,
      @required this.dateController,
      @required this.entryTimeController,
      @required this.ticketNumberController,
      @required this.checkPointController,
      this.dropDownTitle,
      this.selectedCheckPost,
      this.objectList,
      this.onSelected,
      this.isFineScreen = false,
      this.title})
      : super(key: key);

  final TextEditingController dateController;
  final TextEditingController entryTimeController;
  final TextEditingController ticketNumberController;
  final TextEditingController checkPointController;
  final String title;
  final String dropDownTitle;
  final bool isFineScreen;
  final Map<String, String> objectList;
  final Function onSelected;
  final String selectedCheckPost;

  @override
  _TicketInformationSectionState createState() =>
      _TicketInformationSectionState();
}

class _TicketInformationSectionState extends State<TicketInformationSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title ?? "Enter entry ticket details",
          style: headingTextStyle,
        ),
        widgetSeperator(),
        Text(
          "Ticket information",
          style: SubHeadingTextStyle,
        ),
        SizedBox(
          height: 20,
        ),
        BrtFormField(
          title: "Date",
          controller: widget.dateController,
          isReadOnly: true,
        ),
        BrtFormField(
          title: "Entry time",
          controller: widget.entryTimeController,
          isReadOnly: true,
        ),
        BrtFormField(
          title: "Ticket Number",
          controller: widget.ticketNumberController,
          isReadOnly: true,
        ),
        !widget.isFineScreen
            ? BRTDropDownMenu(
                items: widget.objectList.values.toList(),
                title: widget.dropDownTitle,
                onSelected: widget.onSelected,
                selectedItem: widget.objectList[widget.selectedCheckPost],
              )
            : Container()
      ],
    );
  }
}
