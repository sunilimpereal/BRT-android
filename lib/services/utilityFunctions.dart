import 'dart:math';

import 'package:BRT/main.dart';
import 'package:BRT/screens/ticketinfo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../strings.dart';

String getFormattedDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

String getFormattedTime(DateTime dateTime) {
  return DateFormat.jm().format(dateTime);
}

getTime(String time) {
  return time.split('.').first.padLeft(8, "0");
}

DateTime getDateFromString(String formattedString) {
  return formattedString == null ? null : DateTime.parse(formattedString);
}

String getViolationById(int id) {
  return fines[fineID.indexOf(id)];
}

Future<String> getTicketNumber() async {
  String ticketNumber = "BRT" + userId.toString();
  var ran = Random();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int number = preferences.getInt('ticketNumber');
  if (number == null) {
    number = 0;
    preferences.setInt('ticketNumber', number + 1);
  }
  int random = ran.nextInt(99);
  ticketNumber += random.toString().padLeft(0);
  ticketNumber +=
      DateTime.now().month.toString() + DateTime.now().day.toString();
  ticketNumber += number.toString().padLeft(4, "0");

  return ticketNumber;
}

void launchURL(String link, {LinkType linkType}) async {
  String url;
  if (link.isNotEmpty) {
    if (linkType == LinkType.Email) {
      url = Uri(
        scheme: 'mailto',
        path: link,
      ).toString();
    } else if (linkType == LinkType.Phone) {
      url = 'tel:$link';
    } else {
      url = link;
    }
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}

void showSnackbar(GlobalKey<ScaffoldState> scaffoldKey, String title,
    {Function onClosed}) {
  scaffoldKey.currentState
      .showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text(title),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ))
      .closed
      .then((_) => onClosed);
}
