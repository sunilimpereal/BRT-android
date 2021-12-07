import 'dart:developer';

import 'package:BRT/trip/data/models/end_trip_request_model.dart';
import 'package:BRT/trip/data/repository/trip_trpository.dart';
import 'package:BRT/trip/trip_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'start_trip_screen.dart';

class EndTripScreen extends StatefulWidget {
  const EndTripScreen({Key key}) : super(key: key);

  @override
  State<EndTripScreen> createState() => _EndTripScreenState();
}

class _EndTripScreenState extends State<EndTripScreen> {
  TextEditingController deviceId = new TextEditingController();
  FocusNode deviceIdFocusNode = FocusNode();
  String errorMsg = "";
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    if (errorMsg.isNotEmpty) {
      Future.delayed(Duration(seconds: 5)).then((value) {
        setState(() {
          errorMsg = "";
        });
      });
    }
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
                if (deviceIdFocusNode.hasFocus) {
                } else {}
              });
            } else if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
            } else {
              if (event.character != null || !event.isKeyPressed(LogicalKeyboardKey.enter)) {
                log(event.character);
                setState(() {
                  if (deviceIdFocusNode.hasFocus) {
                    deviceId.text = deviceId.text + event.character;
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
                      controller: deviceId,
                      focusNode: deviceIdFocusNode,
                      onSubmitted: (value) {},
                      readOnly: true,
                      hint: "Device ID",
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: const [
                    //     Text("OR",
                    //         style: TextStyle(
                    //             fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16)),
                    //   ],
                    // ),
                    // TripTextField(
                    //   controller: naturalListId,
                    //   readOnly: true,
                    //   focusNode: naturalListIdFocusNode,
                    //   onSubmitted: (value) {},
                    //   hint: "Natural List ID",
                    // ),
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
                          text('Date & Time ',
                              DateFormat().addPattern("hh:mm dd/MM/yyyy").format(DateTime.now())),
                          // text('Driver', "Driver Details"),
                          // text('Natural List', "Natural List Details"),
                          text('Device', "${deviceId.text}"),
                          // text('Natural List', "Vehicle Details"),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        button(
                          name: "End Trip",
                          loading: loading,
                          onTap: () {
                            if (validate()) {
                              setState(() {
                                loading = true;
                              });
                              TripRepository()
                                  .endTrip(
                                      endTripRequestModel:
                                          EndTripRequestModel(tripid: deviceId.text))
                                  .then((value) {
                                setState(() {
                                  loading = false;
                                });
                                if (value == null) {
                                  setState(() {
                                    errorMsg = 'End Trip Failed';
                                  });
                                } else {
                                  setState(() {
                                    errorMsg = 'Trip Ended Successfully';
                                  });
                                }

                                print('Trip Ended Successfully');
                                clear();
                              });
                            } else {
                              setState(() {
                                loading = false;
                              });
                              setState(() {
                                errorMsg = 'Please fill all the fields';
                              });
                            }
                          },
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text("$errorMsg")],
                        )
                      ],
                    )),
              ],
            ),
          ),
        ));
  }

  bool validate() {
    if (deviceId.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  clear() {
    setState(() {
      deviceId.clear();
    });
  }
}
