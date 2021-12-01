import 'dart:developer';

import 'package:BRT/trip/trip_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'start_trip_screen.dart';

class EndTripScreen extends StatefulWidget {
  const EndTripScreen({Key key}) : super(key: key);

  @override
  State<EndTripScreen> createState() => _EndTripScreenState();
}

class _EndTripScreenState extends State<EndTripScreen> {
  TextEditingController driverId = new TextEditingController();
  FocusNode driverIDFocusNode = FocusNode();
  TextEditingController naturalListId = new TextEditingController();
  FocusNode naturalListIdFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'End Trip',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.green,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (event) {
            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              setState(() {
                if (driverIDFocusNode.hasFocus) {
                  naturalListId.clear();
                  naturalListIdFocusNode.requestFocus();
                } else {}
              });
            } else if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
            } else {
              if (event.character != null) {
                log(event.character);
                setState(() {
                  if (driverIDFocusNode.hasFocus) {
                    driverId.text = driverId.text + event.character;
                  } else if (naturalListIdFocusNode.hasFocus) {
                    naturalListId.text = naturalListId.text + event.character;
                  }
                });
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TripTextField(
                      controller: driverId,
                      focusNode: driverIDFocusNode,
                      onSubmitted: (value) {},
                      readOnly: true,
                      hint: "Driver ID",
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("OR",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                    TripTextField(
                      controller: naturalListId,
                      readOnly: true,
                      focusNode: naturalListIdFocusNode,
                      onSubmitted: (value) {},
                      hint: "Natural List ID",
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Scanned Trip Details",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          text('Start Date & Time ', "12/11/2020 18:00"),
                          text('Driver', "Driver Details"),
                          text('Natural List', "Natural List Details"),
                          text('Device', "Device Details"),
                          text('Natural List', "Vehicle Details"),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: button(
                      name: "End Trip",
                      onTap: () {
                        if (valid()) {
                          print('end trip');
                        } else {
                          print("incomplete");
                        }
                      },
                    ))
              ],
            ),
          ),
        ));
  }

  bool valid() {
    if (driverId.text.isNotEmpty && naturalListId.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
