import 'package:flutter/material.dart';

import '../../constants.dart';
import '../brtFormfield.dart';
import '../utilityWidgets.dart';

class DriverDetailsSection extends StatelessWidget {
  const DriverDetailsSection({
    Key key,
    @required this.driverNameController,
    @required this.driverMobileController,
  }) : super(key: key);

  final TextEditingController driverNameController;
  final TextEditingController driverMobileController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Driver Details",
          style: SubHeadingTextStyle,
        ),
        widgetSeperator(),
        BrtFormField(
            title: "Driver Name",
              icon: Icons.person,
            controller: driverNameController,
            validator: (string) {
              if (string.isEmpty) {
                return "required";
              }
            }),
        BrtFormField(
            textInputType: TextInputType.phone,
            title: "Mobile Number",
              icon: Icons.call,
            maxLength: 10,
            validator: (string) {
              if (string.isEmpty) {
                return "required";
              }
            },
            controller: driverMobileController),
      ],
    );
  }
}
