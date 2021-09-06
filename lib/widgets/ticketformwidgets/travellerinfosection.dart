import 'package:flutter/material.dart';

import '../../constants.dart';
import '../brtFormfield.dart';
import '../utilityWidgets.dart';

class TravellerDetailsSection extends StatelessWidget {
  const TravellerDetailsSection({
    Key key,
    @required this.numberOfTravelersController,
  }) : super(key: key);

  final TextEditingController numberOfTravelersController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Travellers details",
          style: SubHeadingTextStyle,
        ),
        widgetSeperator(),
        BrtFormField(
            textInputType: TextInputType.number,
            title: "Number of travelers",
            controller: numberOfTravelersController),
      ],
    );
  }
}
