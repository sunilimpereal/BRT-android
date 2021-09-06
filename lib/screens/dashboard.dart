import 'dart:async';
import 'dart:convert';

import 'package:BRT/constants.dart';
import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/models/ticketCount.dart';
import 'package:BRT/repositories/dropdowndata.dart';
import 'package:BRT/repositories/raisefineticketsDao.dart';
import 'package:BRT/repositories/ticketcountDao.dart';
import 'package:BRT/screens/tickethistory.dart';
import 'package:BRT/screens/ticketinfo.dart';
import 'package:BRT/services/printer.dart';
import 'package:BRT/services/utilityFunctions.dart';
import 'package:BRT/services/variables.dart';
import 'package:BRT/viewmodels/authentication.dart';
import 'package:BRT/viewmodels/checkpostviewmodel.dart';
import 'package:BRT/viewmodels/ticketviewmodel.dart';
import 'package:BRT/widgets/MenuTile.dart';
import 'package:BRT/widgets/qrscan.dart';
import 'package:BRT/widgets/underlinebutton.dart';
import 'package:BRT/widgets/utilityWidgets.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  TicketViewModel ticketVM;

  TicketCountDao ticketCountDao;
  Printer printer;
  Key _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController syncController;
  Animation<double> syncAnimation;

  @override
  void initState() {
    init();
    getTicketCount();
    initLocalSync();
    super.initState();
    syncController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..addListener(() {
        if (syncController.status == AnimationStatus.completed) {
          syncController.reset();
          // syncController.forward();
        }
        // setState(() {}); // DONT DO THIS
      });
    syncAnimation = Tween<double>(begin: 1, end: 4).animate(
        new CurvedAnimation(parent: syncController, curve: Curves.linear));

    getSyncTime();
  }

  saveTime() async {
    setState(() {
      lastSyncTime = getFormattedTime(DateTime.now());
    });

    final preferences = await SharedPreferences.getInstance();
    preferences.setString('syncTime', getFormattedTime(DateTime.now()));
  }

  init() {
    dropDownDataDao = DropDownDataDao();
    ticketVM = TicketViewModel(accessToken);
    ticketCountDao = TicketCountDao();
  }

  getTicketCount() async {
    return ticketCount;
  }

  syncDataWithBackEnd() async {
    ticketCollectorDao.deleteTicketCollection();
    syncController.forward();
    final List a = await entryDao.getAllEntryTickets();
    final List fineTicket = await fineDao.getAllFineTickets();
    final List raisedFineTickets =
        await raisedFineDao.getAllRaisedFineTickets();
    if (a.isNotEmpty) {
      for (EntryTicketModel ticket in a) {
        final response = await ticketVM.updateTicket(
          EntryTicketModel(
              date: ticket.date,
              entryTime: ticket.entryTime,
              exitCheckPoint: ticket.exitCheckPoint,
              exitTime: ticket.exitTime,
              fine: ticket.fine,
              hasExited: ticket.hasExited,
              keeperID: ticket.keeperID,
              numberOfTravelers: ticket.numberOfTravelers,
              stayStatus: ticket.stayStatus,
              ticketNumber: ticket.ticketNumber,
              totalfine: ticket.totalfine,
              vehicle: ticket.vehicle,
              entryCheckPoint: availableCheckPost
                  .firstWhere((element) =>
                      element.name == ticket.entryCheckPoint ||
                      element.id == ticket.entryCheckPoint)
                  .id),
        );
        if (response.didSucceed) {
          await entryDao.remove(ticket);
        }
      }
    }
    if (fineTicket.isNotEmpty) {
      for (var ticket in fineTicket) {
        final response = await ticketVM.saveFineTicket(ticket);
        if (response.didSucceed) {
          fineDao.remove(ticket);
        }
      }
    }
    if (raisedFineTickets.isNotEmpty) {
      for (var ticket in raisedFineTickets) {
        final response = await ticketVM.raiseFine(ticket);
        if (response.didSucceed) {
          raisedFineDao.remove(ticket);
        }
      }
    }
    final count = await ticketVM.getTicketCount();
    ticketCount = count;
    if (ticketCountDao.getAllCountsFromLocal() == null) {
      await ticketCountDao.insertTicketCount(ticketCount);
    } else {
      await ticketCountDao.updateTicketCount(ticketCount);
    }
    final tickets = await ticketVM.getTicketsByDate(DateTime.now());

    for (var ticket in tickets.reversed) {
      ticketCollectorDao.insert(ticket);
    }

    saveTime();
    syncController.stop();
  }

  initLocalSync() async {
    setState(() {
      _isLoading = true;
    });

    if (!isDeviceOnline) {
      if (availableStates.isEmpty) {
        availableStates = await dropDownDataDao.getAllStatesFromLocal();
      }
      if (availableReserves.isEmpty) {
        availableReserves = await dropDownDataDao.getAllReservesFromLocal();
      }
      if (availableCheckPost.isEmpty) {
        availableCheckPost = await dropDownDataDao.getAllCheckPostsFromLocal();
      }
      // if (ticketCount == null) {
      final temp = await ticketCountDao.getAllCountsFromLocal();
      final temp2 = await entryDao.getOfflineTicketCount();

      ticketCount = TicketCountModel(
          vehicleInside:
              (int.parse(temp.vehicleInside) + int.parse(temp2.vehicleInside))
                  .toString(),
          entryTickets:
              (int.parse(temp.entryTickets) + int.parse(temp2.entryTickets))
                  .toString(),
          fineTickets:
              (int.parse(temp.fineTickets) + int.parse(temp2.fineTickets))
                  .toString());
      // }
    } else {
      final states = await ticketVM.getStatesList();
      availableStates = states;

      if (await dropDownDataDao.isStateDataEmpty()) {
        for (var state in states) {
          dropDownDataDao.insertStates(state);
        }
      }
      final count = await ticketVM.getTicketCount();
      ticketCount = count;
      if (await ticketCountDao.getAllCountsFromLocal() == null) {
        await ticketCountDao.insertTicketCount(ticketCount);
      } else {
        await ticketCountDao.updateTicketCount(ticketCount);
      }

      final reserves = await ticketVM.getReserveStayList();
      availableReserves = reserves;
      if (await dropDownDataDao.isReserveDataEmpty()) {
        for (var reserve in reserves) {
          dropDownDataDao.insertReserves(reserve);
        }
      }

      final checkposts =
          await CheckPostViewModel(accessToken).getCheckPostList();
      availableCheckPost = checkposts;
      if (await dropDownDataDao.isCheckPostDataEmpty()) {
        for (var cp in checkposts) {
          dropDownDataDao.insertCheckPost(cp);
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
    saveTime();
  }

  Future<void> selectPrinter() async {
    final result = await printer.selectPrinter();
  }

  getSyncTime() async {
    final preferences = await SharedPreferences.getInstance();
    lastSyncTime = preferences.getString('syncTime');
  }

  EntryTicketModel getQrInfo(String text) {
    EntryTicketModel ticket = EntryTicketModel.fromJson(text);
    return ticket;
  }

  @override
  Widget build(BuildContext context) {
    printer = Printer();

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: BrtWhite,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : FutureBuilder(
                    future: getTicketCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Padding(
                          padding: GlobalScreenPadding,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      assetsDirectory + "LogoIcon.png",
                                      height: 70,
                                      width: 70,
                                    ),
                                    Expanded(child: Container()),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: GestureDetector(
                                                onTap: () async {
                                                  await selectPrinter();
                                                },
                                                child: Icon(
                                                  Icons.print,
                                                  color: BRTbrown,
                                                )),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (!isDeviceOnline) {
                                                  showSnackbar(_scaffoldKey,
                                                      "Please check internet Connectivity");
                                                  return;
                                                }
                                                syncDataWithBackEnd();
                                              },
                                              child: AnimatedBuilder(
                                                  animation: syncAnimation,
                                                  builder: (context, child) {
                                                    return Transform.rotate(
                                                        angle:
                                                            syncAnimation.value,
                                                        child: Icon(
                                                          Icons.sync,
                                                          color: BRTbrown,
                                                        ));
                                                  }),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context, TicketInfoRoute);
                                                  Provider.of<AuthenticationViewModel>(
                                                          context,
                                                          listen: false)
                                                      .logout();
                                                  Navigator
                                                      .pushNamedAndRemoveUntil(
                                                          context,
                                                          LoginRoute,
                                                          (route) => false);
                                                },
                                                child: Image.asset(
                                                    "assets/images/LogoutIcon.png")),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: lastSyncTime != null
                                    ? Text("Last Sync at $lastSyncTime")
                                    : Container(),
                              ),
                              Stack(children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: BRTbrown,
                                  ),
                                  padding: GlobalScreenPadding,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: BrtMediumBrown,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Image.asset(
                                              
                                              assetsDirectory +
                                                "VehicleCountIcon.png",color: Colors.green,)),
                                      ),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data.vehicleInside ?? "",
                                              style: TextStyle(
                                                  fontSize: 35,
                                                  color: BrtWhite),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Vehicles Inside",
                                                  style: TextStyle(
                                                      color: BrtWhite),
                                                ),
                                              ],
                                            )
                                          ])
                                    ],
                                  ),
                                ),
                                Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: onVehicleCardTapped,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Image.asset(
                                          assetsDirectory + "NextIcon.png",
                                          scale: 0.6,
                                          
                                        ),
                                      ),
                                    ))
                              ]),
                              widgetSeperator(),
                              widgetSeperator(),
                              // MenuTile(
                              //   title: "Make entry ticket",
                              //   subtitle: snapshot.data.entryTickets +
                              //       " entry tickets made",
                              //   buttonText: "Add",
                              //   icon: assetsDirectory + "EntryTicketIcon.png",
                              //   onPressed: () async {
                              //     try {
                              //       await Navigator.pushNamed(
                              //               context, EntryTicketRoute)
                              //           .timeout(TimeOutDuration);
                              //       if (isDeviceOnline) {
                              //         syncDataWithBackEnd();
                              //       } else {
                              //         initLocalSync();
                              //       }
                              //     } on TimeoutException catch (_) {
                              //       print(_);
                              //     }
                              //   },
                              // ),
                              MenuTile(
                                title: "Make fine ticket",
                                subtitle: snapshot.data.fineTickets +
                                    " fine tickets made",
                                buttonText: "Add",
                                icon: assetsDirectory + "FineTicketIcon.png",
                                onPressed: () async {
                                  try {
                                    await Navigator.pushNamed(
                                            context, FineTicketRoute)
                                        .timeout(TimeOutDuration);
                                    if (isDeviceOnline) {
                                      syncDataWithBackEnd();
                                    } else {
                                      initLocalSync();
                                    }
                                  } on TimeoutException catch (_) {
                                    print(_);
                                  }
                                },
                              ),
                              // MenuTile(
                              //     title: "Scan a ticket",
                              //     subtitle: "Scan for exit or fine",
                              //     buttonText: "Scan",
                              //     icon: assetsDirectory + "ScanIcon.png",
                              //     onPressed: () async {
                              //       String barCodeResult = //"37";
                              //           await FlutterBarcodeScanner.scanBarcode(
                              //               "#ff6666",
                              //               "Cancel",
                              //               true,
                              //               ScanMode.DEFAULT);
                              //       if (barCodeResult != null &&
                              //           barCodeResult != "-1") {
                              //         final qrInfo = getQrInfo(barCodeResult);
                              //         Navigator.pushNamed(
                              //             context, TicketInfoRoute,
                              //             arguments: TicketInfoArguments(
                              //                 ticket: qrInfo));
                              //       }
                              //     }),
                              // GestureDetector(
                              //     onTap: () async {
                              //       await Navigator.pushNamed(
                              //           context, TicketHistoryRoute,
                              //           arguments: false);
                              //       if (isDeviceOnline) {
                              //         syncDataWithBackEnd();
                              //       } else {
                              //         initLocalSync();
                              //       }
                              //     },
                              //     child: UnderLineButton("View all tickets")),
                            ],
                          ),
                        );
                      }
                    }),
          ),
        ),
      ),
    );
  }

  onVehicleCardTapped() async {
    try {
      await Navigator.pushNamed(context, TicketHistoryRoute, arguments: true)
          .timeout(TimeOutDuration);
      initLocalSync();
    } on TimeoutException catch (_) {
      print(_);
    }
  }
}
