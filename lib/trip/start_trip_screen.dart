import 'dart:developer';

import 'package:BRT/trip/data/models/start_trip_request_model.dart';
import 'package:BRT/trip/data/repository/trip_trpository.dart';
import 'package:BRT/trip/trip_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class StartTripScreen extends StatefulWidget {
  const StartTripScreen({Key key}) : super(key: key);

  @override
  State<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends State<StartTripScreen> {
  TextEditingController driverID = new TextEditingController();
  TextEditingController naturalListId = new TextEditingController();
  TextEditingController deviceID = TextEditingController();
  TextEditingController vehicleID = new TextEditingController();
  FocusNode driverIDFocusNode = FocusNode();
  FocusNode naturalListIdFocusNode = FocusNode();
  FocusNode deviceIDFocusNode = FocusNode();
  FocusNode vehicleIDFocusNode = FocusNode();
  String errorMsg = "";
  bool loading = false;
  bool enterPressed = false;
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
  }

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
            'Start Trip',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          leading: IconButton(
            icon: const Icon(
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
            if (!enterPressed&& event.isKeyPressed(LogicalKeyboardKey.enter)) {

              log("enter Pressed");
              setState(() {
                enterPressed = true;
                if (driverIDFocusNode.hasFocus) {
                  naturalListId.clear();
                  naturalListIdFocusNode.requestFocus();
                } else if (naturalListIdFocusNode.hasFocus) {
                  deviceID.clear();
                  deviceIDFocusNode.requestFocus();
                } else if (deviceIDFocusNode.hasFocus) {
                  vehicleID.clear();
                  vehicleIDFocusNode.requestFocus();
                } else if (vehicleIDFocusNode.hasFocus) {
                  driverIDFocusNode.requestFocus();
                } else {}
              });
            } else if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
            } else {
              if (event.character != null|| !event.isKeyPressed(LogicalKeyboardKey.enter)) {

                log("event : "+event.data.toString());
                setState(() {
                 
                  if (driverIDFocusNode.hasFocus) {
                    driverID.text = driverID.text + event.character;
                  } else if (driverIDFocusNode.hasFocus) {
                    driverID.text = driverID.text + event.character;
                  } else if (naturalListIdFocusNode.hasFocus) {
                    naturalListId.text = naturalListId.text + event.character;
                  } else if (deviceIDFocusNode.hasFocus) {
                    deviceID.text = deviceID.text + event.character;
                  } else if (vehicleIDFocusNode.hasFocus) {
                    vehicleID.text = vehicleID.text + event.character;
                  } else {}
                });
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TripTextField(
                      controller: driverID,
                      focusNode: driverIDFocusNode,
                      readOnly: true,
                      onSubmitted: (value) {
                        naturalListIdFocusNode.requestFocus();
                      },
                      hint: "Driver ID",
                    ),
                    TripTextField(
                      controller: naturalListId,
                      focusNode: naturalListIdFocusNode,
                      readOnly: true,
                      hint: "Natural List ID",
                      onSubmitted: (value) {
                        deviceIDFocusNode.requestFocus();
                      },
                    ),
                    TripTextField(
                      controller: deviceID,
                      focusNode: deviceIDFocusNode,
                      readOnly: true,
                      onSubmitted: (value) {
                        vehicleIDFocusNode.requestFocus();
                      },
                      hint: "Device ID",
                    ),
                    TripTextField(
                      controller: vehicleID,
                      focusNode: vehicleIDFocusNode,
                      readOnly: true,
                      onSubmitted: (value) {},
                      hint: "Vehicle ID",
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Details",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          text('Date & Time ',
                              DateFormat().addPattern("hh:mm dd/MM/yyyy").format(DateTime.now())),
                          text('Driver', "${driverID.text}"),
                          text('Natural List', "${naturalListId.text}"),
                          text('Device', "${deviceID.text}"),
                          text('Vehicle', "${vehicleID.text}"),
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
                          name: "Start Trip",
                          loading: loading,
                          onTap: () {
                            setState(() {
                              loading = true;
                            });
                            if (validate()) {
                              TripRepository()
                                  .startTrip(
                                      startTripRequestModel: StartTripRequestModel(
                                        sfrDevice: deviceID.text,
                                        sfrDriver: driverID.text,
                                        sfrNaturelist: naturalListId.text,
                                        sfrVehicle: vehicleID.text,
                                      ),
                                      context: context)
                                  .then((value) {
                                setState(() {
                                  loading = false;
                                });
                                if (value == null) {
                                    setState(() {
                                  errorMsg = 'Trip Start Failed';
                                });
                                }
                                setState(() {
                                  errorMsg = 'Trip Started Successfully';
                                });
                                print('Trip Started Successfully');
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
                    ))
              ],
            ),
          ),
        ));
  }

  bool validate() {
    log("message");
    if (driverID.text.isNotEmpty &&
        naturalListId.text.isNotEmpty &&
        deviceID.text.isNotEmpty &&
        vehicleID.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  clear() {
    setState(() {
      driverID.clear();
      naturalListId.clear();
      deviceID.clear();
      vehicleID.clear();
    });
  }
}

Widget text(String title, String value) {
  return Text('$title : $value', style: const TextStyle(color: Colors.grey));
}

Widget button({String name, Function() onTap, bool loading}) {
  return ActionChip(
    backgroundColor: Colors.green.shade800,
    onPressed: onTap,
    label: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
      child: !loading
          ? Text(
              name,
              style: const TextStyle(color: Colors.white),
            )
          : Container(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
              )),
    ),
  );
}
