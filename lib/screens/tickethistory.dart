import 'dart:async';

import 'package:BRT/main.dart';
import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/models/states.dart';
import 'package:BRT/repositories/dropdowndata.dart';
import 'package:BRT/screens/ticketinfo.dart';

import 'package:BRT/services/utilityFunctions.dart';
import 'package:BRT/viewmodels/ticketviewmodel.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class TicketHistoryScreen extends StatefulWidget {
  final bool isEntryOnlyHistory;
  TicketHistoryScreen({this.isEntryOnlyHistory = false});
  @override
  _TicketHistoryScreenState createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  bool _isLoading = false;
  TicketViewModel ticketViewModel;
  DateTime dateTime = DateTime.now();
  List<StatesModel> states = [];

  @override
  void initState() {
    ticketViewModel = TicketViewModel(accessToken);
    setState(() {
      _isLoading = true;
    });
    init();

    super.initState();
  }

  Future init() async {
    await getStates();
    await getTickets();
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<EntryTicketModel>> getTickets() async {
    if (!isDeviceOnline) {
      final tickets = await ticketCollectorDao.getTicketsByDate(dateTime);
      return widget.isEntryOnlyHistory
          ? tickets
              .where((element) =>
                  element.hasExited == false &&
                  element.hasExited == false &&
                  element.stayStatus == null)
              .toList()
          : tickets;
    } else {
      try {
        final tickets = await ticketViewModel
            .getTicketsByDate(dateTime.toUtc())
            .timeout(TimeOutDuration);
        return widget.isEntryOnlyHistory
            ? tickets
                .where((element) =>
                    element.hasExited == false && element.stayStatus == null)
                .toList()
            : tickets;
      } on TimeoutException catch (_) {
        final tickets = await ticketCollectorDao.getTicketsByDate(dateTime);
        return widget.isEntryOnlyHistory
            ? tickets
                .where((element) =>
                    element.hasExited == false && element.stayStatus == null)
                .toList()
            : tickets;
      }
    }
  }

  getStates() async {
    if (!isDeviceOnline) {
      final list = await dropDownDataDao.getAllStatesFromLocal();
      states.addAll(list);
    } else {
      try {
        final list =
            await ticketViewModel.getStatesList().timeout(TimeOutDuration);
        states.addAll(list);
      } on TimeoutException catch (_) {
        final list = await dropDownDataDao.getAllStatesFromLocal();
        states.addAll(list);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: Padding(
          padding: GlobalScreenPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All Tickets",
                  style: headingTextStyle,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getFormattedDate(dateTime),
                        style: TextStyle(fontSize: 17),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final DateTime picked = await showDatePicker(
                              builder: (_, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                    primary: BRTbrown,
                                  )),
                                  child: child,
                                );
                              },
                              context: context,
                              initialDate: dateTime,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030));
                          if (picked != null && picked != dateTime) {
                            setState(() {
                              dateTime = picked;
                            });
                          }
                        },
                        child: Text(
                          "Change",
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                        ),
                      )
                    ],
                  ),
                ),
                FutureBuilder<List<EntryTicketModel>>(
                  future: getTickets(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<EntryTicketModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.data.isEmpty || snapshot.data == null) {
                      return Center(
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: 250),
                              child: Text("No Tickets Found")));
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.hasData) {
                      return Column(
                        children: [
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                final dateTime = DateTime.parse(
                                        snapshot.data[index].entryTime)
                                    .toLocal();
                                final time =
                                    getFormattedTime(dateTime).toString();
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        TicketInfoRoute,
                                        arguments: TicketInfoArguments(
                                            isQrScanned:
                                                widget.isEntryOnlyHistory
                                                    ? true
                                                    : false,
                                            ticket: snapshot.data[index]),
                                      );
                                    },
                                    child: TicketTile(
                                      entryTime: time,
                                      hasExited: snapshot.data[index].hasExited,
                                      totalFine: snapshot.data[index].totalfine,
                                      ticketNumber:
                                          snapshot.data[index].ticketNumber,
                                      vehicleNumber: states
                                              .firstWhere((element) =>
                                                  element.id ==
                                                  snapshot.data[index].vehicle
                                                      .state)
                                              .rtoCode +
                                          " " +
                                          snapshot.data[index].vehicle
                                              .districtCode +
                                          " " +
                                          snapshot.data[index].vehicle.series +
                                          " " +
                                          snapshot
                                              .data[index].vehicle.uniqueNumber,
                                      status: snapshot.data[index].exitTime,
                                    ),
                                  ),
                                );
                              }),
                        ],
                      );
                      // ListView.builder(
                      //     shrinkWrap: true,
                      //     itemBuilder: (context, index) => TicketTile())

                    }
                  },
                )
              ],
            ),
          ),
        ));
  }
}

class TicketTile extends StatelessWidget {
  TicketTile(
      {this.ticketNumber,
      this.entryTime,
      this.status,
      this.vehicleNumber,
      this.hasExited,
      this.totalFine});
  final String ticketNumber;
  final String status;
  final String vehicleNumber;
  final String entryTime;
  final String totalFine;
  final bool hasExited;

  @override
  Widget build(BuildContext context) {
    bool exited = hasExited;
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Ticket Number $ticketNumber",
          style: TextStyle(color: Color(0xFF194038), fontSize: 17),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                color: exited ? Color(0xFFDAEFEB) : Color(0xFFFEF8EA),
                padding: EdgeInsets.all(5),
                child: Text(
                  exited
                      ? "Vehicle has Exited BR Hills"
                      : "Vehicle Is In BR Hills",
                  style: TextStyle(
                      color: exited ? Color(0XFF67BDAC) : Color(0xFFF4CA5F)),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            double.parse(totalFine) != 0 && totalFine != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      color: Color(0xFFFBECEC),
                      padding: EdgeInsets.all(5),
                      child: Text(
                        "Fine INR $totalFine",
                        style: TextStyle(color: Color(0XFFE47B7B)),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Vehicle Number: $vehicleNumber"),
          SizedBox(
            height: 5,
          ),
          Text("Entry Time: $entryTime")
        ])
      ]),
    );
  }
}
