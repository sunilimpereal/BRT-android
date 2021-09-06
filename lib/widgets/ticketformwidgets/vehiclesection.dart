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
          width: double.infinity,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: (MediaQuery.of(context).size.width /
                    MediaQuery.of(context).size.height) *
                1.2,
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
        )
      ],
    );
  }
}
