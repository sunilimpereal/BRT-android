import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants.dart';
import '../brtFormfield.dart';
import '../dropdown.dart';

class VehicleNumberSection extends StatefulWidget {
  VehicleNumberSection(
      {this.districtNumberController,
      this.selectedState,
      this.objectList,
      this.letterController,
      this.onSelected,
      this.key,
      this.uniqueNumberController});
  final Key key;
  final TextEditingController districtNumberController;
  final TextEditingController letterController;
  final TextEditingController uniqueNumberController;
  final Function onSelected;
//  final List<dynamic> objectList;
  final Map<String, dynamic> objectList;
  String selectedState;

  @override
  _VehicleNumberSectionState createState() => _VehicleNumberSectionState();
}

class _VehicleNumberSectionState extends State<VehicleNumberSection> {
  List<String> states = [];
  Map<String, String> statess = Map();

  @override
  void initState() {
    //getStates();
    super.initState();
  }

  // getStates() async {
  //   for (var state in widget.objectList) {
  //     statess.putIfAbsent(state.id, () => state.name);
  //     print(statess);
  //   }
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: widget.key,
      crossAxisAlignment: CrossAxisAlignment.start,
       textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          "Vehicle number",
          style: SubHeadingTextStyle,
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          children: [
            BRTDropDownMenu(
              items: widget.objectList.values.toList(),
              title: "State",
              onSelected: widget.onSelected,
              selectedItem: widget.objectList[widget.selectedState],
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                 textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: BrtFormField(
                          title: "District No.",
                          maxLength: 2,
                          validator: (string) {
                            if (string.isEmpty) {
                              return "required";
                            }
                          },
                          textInputType: TextInputType.number,
                          controller: widget.districtNumberController),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: BrtFormField(
                      capitalization: TextCapitalization.characters,
                      textInputType: TextInputType.text,
                      title: "Letters",
                      controller: widget.letterController,
                      validator: (string) {
                        if (string.isEmpty) {
                          return "required";
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: BrtFormField(
                        title: "Unique No.",
                        maxLength: 4,
                        validator: (string) {
                          if (string.isEmpty) {
                            return "required";
                          }
                        },
                        textInputType: TextInputType.number,
                        controller: widget.uniqueNumberController),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
