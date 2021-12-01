import 'package:flutter/material.dart';


//utility Contants
// const BackendBaseUrl = "https://brt.codemonk.in/api/v1/";
const BackendBaseUrl = "http://ntr.afroaves.com:8082/api/v1/";
const assetsDirectory = "assets/images/";
const CHANNEL = 'brother/print';
// Color Constants
const BRTbrown = Color(0xFF291B1B);
const BRTlightBrown = Color(0xFFF8F8F7);
const GlobalScreenPadding = EdgeInsets.all(12);
const BrtWhite = Colors.white;
const Brtblack = Colors.black;
const Brtgrey = Colors.blueGrey;
const BrtSubtitleColor = Color(0xFF3C484F);
const BrtGreen = Color(0xFF3CAB94);
const BrtGray = Color(0xFF919893);
const BrtYellow = Color(0xFFF6D174);
const BrtMediumBrown = Color(0xFF342727);
const BrtdisabledBrown = Color(0xFFA49898);

// Routing constants
const LoginRoute          = "login";
const DashBoardRoute      = "dashboard";
const EntryTicketRoute    = "entry";
const FineTicketRoute     = "fine";
const SplashRoute         = "splash";
const AuthenticationRoute = "authenticate";
const TicketInfoRoute     = "ticketInfo";
const TicketHistoryRoute  = "ticketHistory";

// Style Constants
const headingTextStyle = TextStyle(
  fontSize: 18,
  color: BRTbrown,
  fontFamily: "Montserrat",
  fontWeight: FontWeight.w700,
);
const SubHeadingTextStyle = TextStyle(fontSize: 19, color: Brtblack, fontWeight: FontWeight.w600);

const TimeOutDuration = Duration(seconds: 2);

