import 'dart:async';

import 'package:BRT/constants.dart';
import 'package:BRT/main.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_blue/flutter_blue.dart';

class Printer {
  static const platform = MethodChannel('$CHANNEL');

  Future<void> selectPrinter() async {
    try {
      // FlutterBlue flutterBlue = FlutterBlue.instance;
      // bool isSupport = await flutterBlue.isAvailable;
      // bool isOn = await flutterBlue.isOn;
      // if (isOn == true && isSupport == true) {
      var printStatus = await platform.invokeMethod(
        'select',
        // {'address': "<mac address>", 'bas64': "passBase64String"}
      );
      // } else {
      //   scaffoldKey.currentState.showSnackBar(SnackBar(
      //       content: Text("Bluetooth is off. Please check the settings.")));
      // }
    } catch (err) {}
  }

  // Future<bool> isPrinterConnected() async {
  //   final result = await platform.invokeMethod('printerStatus');
  //   return result == 3 ? true : false;
  // }

  Future<dynamic> printReceipt(Map<String, dynamic> data) async {
    int result;
    try {
      var printStatus = await platform.invokeMethod('print', data);
      if (printStatus == -1) {
        return false;
      }
      print(printStatus);
    } on PlatformException catch (e) {
      print('$e');
    }
  }

  void getPrinterStatus() {
    const EventChannel _stream = EventChannel('printingStatus');
    _stream.receiveBroadcastStream().listen((event) {
      printerStatus = event;
      print("Printer status: $event");
    });
  }
}
