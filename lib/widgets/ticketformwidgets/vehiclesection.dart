import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../strings.dart';
import '../iconcontainer.dart';
import '../utilityWidgets.dart';

class VehicleSelectionSection extends StatelessWidget {
  const VehicleSelectionSection(
      {Key key, @required this.vehicleType, this.onChanged})
      : super(key: key);

  final String vehicleType;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Vehicle type",
          style: SubHeadingTextStyle,
        ),
        widgetSeperator(),
        Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                    vehicles.length,
                    (index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconContainer(
                            title: vehicles[index],
                            groupValue: vehicleType,
                            icon: vehicleIcons[index],
                            value: vehicles[index],
                            onChnaged: (x) => onChanged(x),
                          ),
                        )),
              ),
            )),
      ],
    );
  }
}
