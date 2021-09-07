import 'dart:developer';

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../strings.dart';
import '../iconcontainer.dart';
import '../utilityWidgets.dart';

class VehicleSelectionSection extends StatefulWidget {
  const VehicleSelectionSection(
      {Key key, @required this.vehicleType, this.onChanged})
      : super(key: key);

  final String vehicleType;
  final Function(String) onChanged;

  @override
  State<VehicleSelectionSection> createState() =>
      _VehicleSelectionSectionState();
}

class _VehicleSelectionSectionState extends State<VehicleSelectionSection> {
  ScrollController scrollController = ScrollController();
  int sc = 0;

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          log("$sc");
          sc = 1;
        });
      }
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        setState(() {
          sc = 0;
        });
      }
    });
    super.initState();
  }

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
        Stack(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                        vehicles.length,
                        (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconContainer(
                                title: vehicles[index],
                                groupValue: widget.vehicleType,
                                icon: vehicleIcons[index],
                                value: vehicles[index],
                                onChnaged: (x) => widget.onChanged(x),
                              ),
                            )),
                  ),
                )),
            Row(
              mainAxisAlignment:
                  sc == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.white.withOpacity(0.2),
                    height: 120,
                    width: 30,
                    child: Center(
                        child: Icon(
                      sc == 1 ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                      size: 40,
                      color: Colors.green.withOpacity(0.3),
                    )),
                  ),
                )
              ],
            )
            // Positioned(
            //     left: sc == 1 ? 0 : null,
            //     right: sc == 0 ? 0 : null,
            //     bottom: 70,
            //     child:  Icon(
            //            sc == 1
            //         ? Icons.arrow_back_ios: Icons.arrow_forward_ios,
            //             size: 40,color: Colors.green.withOpacity(0.1),
            //           )
            //        ),
          ],
        ),
      ],
    );
  }
}
