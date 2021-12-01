import 'package:flutter/material.dart';

class QrScanner extends StatefulWidget {
  @override
  _QrScannerState createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  String barCodeResult = "Scan";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // child: RaisedButton(
        //   onPressed: () async {
        //     barCodeResult = await FlutterBarcodeScanner.scanBarcode(
        //         "#ff6666", "Cance", true, ScanMode.DEFAULT);
        //     setState(() {});
        //   },
        //   child: Text(barCodeResult),
        // ),
      ),
    );
  }
}
