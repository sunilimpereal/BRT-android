import 'package:BRT/constants.dart';
import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/screens/dashboard.dart';
import 'package:BRT/screens/entryTicket.dart';
import 'package:BRT/screens/fineTicketScreen.dart';
import 'package:BRT/screens/login.dart';
import 'package:BRT/screens/splash.dart';
import 'package:BRT/screens/tickethistory.dart';
import 'package:BRT/screens/ticketinfo.dart';
import 'package:flutter/material.dart';

import 'main.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (context) => SplashScreen());
    case LoginRoute:
      return MaterialPageRoute(builder: (context) => LoginPage());
    case DashBoardRoute:
      return MaterialPageRoute(builder: (context) => Dashboard());
    case EntryTicketRoute:
      return MaterialPageRoute(builder: (context) => EntryTicket());
    case FineTicketRoute:
      return MaterialPageRoute(builder: (context) => FineTicket());
    case AuthenticationRoute:
      return MaterialPageRoute(builder: (context) => AuthenticationScreen());
    case TicketHistoryRoute:
      return MaterialPageRoute(
          builder: (context) => TicketHistoryScreen(
                isEntryOnlyHistory: settings.arguments,
              ));
    case TicketInfoRoute:
      TicketInfoArguments argument = settings.arguments;

      return MaterialPageRoute(
          builder: (context) => TicketInfoScreen(
                arguments: argument,
              ));
    default:
      return MaterialPageRoute(builder: (context) => Dashboard());
  }
}
