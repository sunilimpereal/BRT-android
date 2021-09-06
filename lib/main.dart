import 'dart:async';

import 'package:BRT/constants.dart';
import 'package:BRT/repositories/dropdowndata.dart';
import 'package:BRT/repositories/entryTicketDao.dart';
import 'package:BRT/repositories/fineTicketDao.dart';
import 'package:BRT/repositories/raisefineticketsDao.dart';
import 'package:BRT/repositories/ticketcollectordao.dart';
import 'package:BRT/screens/dashboard.dart';
import 'package:BRT/services/printer.dart';
import 'package:BRT/viewmodels/authentication.dart';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'router.dart' as router;

void main() => runApp(MyApp());

String accessToken;
String userId;
String checkPost;
bool isDeviceOnline = false;
ValueNotifier<bool> isOnline = ValueNotifier<bool>(false);
int printerStatus;
EntryTicketDao entryDao = EntryTicketDao();
TicketCollectorDao ticketCollectorDao = TicketCollectorDao();
FineTicketDao fineDao = FineTicketDao();
RaiseFineDao raisedFineDao = RaiseFineDao();
DropDownDataDao dropDownDataDao = DropDownDataDao();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription subscription;
  StreamSubscription printStatusSubscribtion;
  @override
  void initState() {
    super.initState();

    const EventChannel _stream = EventChannel('printingStatus');
    _stream.receiveBroadcastStream().listen((event) {
      printerStatus = event;
      print("Printer status: $event");
    });

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        isDeviceOnline = await DataConnectionChecker().hasConnection;
      } else {
        isDeviceOnline = false;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    subscription.cancel();
    printStatusSubscribtion.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return ChangeNotifierProvider(
      create: (context) => AuthenticationViewModel(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              colorScheme: ThemeData().colorScheme.copyWith(
                    secondary: Colors.green,
                    primary: Colors.green
                  ),
              iconTheme: IconThemeData(color: Colors.green),
              scaffoldBackgroundColor: BrtWhite,
              primaryTextTheme: TextTheme(),
              primaryColor: BrtWhite,
              fontFamily: "Montserrat",
              highlightColor: Colors.green.withOpacity(0.7),
              splashColor: Colors.green,
              outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                primary: Colors.green,
              )),
              cursorColor: BRTbrown),
          onGenerateRoute: router.generateRoute,
          initialRoute: "/"),
    );
  }
}
