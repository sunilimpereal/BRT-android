import 'dart:async';

import 'package:BRT/constants.dart';
import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/models/vehicle.dart';
import 'package:BRT/repositories/ticketcollectordao.dart';
import 'package:BRT/services/printer.dart';
import 'package:BRT/services/utilityFunctions.dart';
import 'package:BRT/services/variables.dart';
import 'package:BRT/strings.dart';
import 'package:BRT/viewmodels/checkpostviewmodel.dart';
import 'package:BRT/viewmodels/ticketviewmodel.dart';
import 'package:BRT/widgets/brtbutton.dart';
import 'package:BRT/widgets/dropdown.dart';
import 'package:BRT/widgets/ticketInfoForm.dart';
import 'package:BRT/widgets/ticketformwidgets/driverinfosection.dart';
import 'package:BRT/widgets/ticketformwidgets/travellerinfosection.dart';
import 'package:BRT/widgets/ticketformwidgets/vehiclenumbersection.dart';
import 'package:BRT/widgets/ticketformwidgets/vehiclesection.dart';
import 'package:BRT/widgets/utilityWidgets.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class EntryTicket extends StatefulWidget {
  @override
  _EntryTicketState createState() => _EntryTicketState();
}

class _EntryTicketState extends State<EntryTicket> {
  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final scrollKey = GlobalKey();

  Map<String, dynamic> statess;
  Map<String, dynamic> checkPosts;
  Map<String, dynamic> reserveStays;

  TicketViewModel ticketVM;
  CheckPostViewModel checkPostVM;

  TextEditingController dateController,
      entryTimeController,
      ticketNumberController,
      checkPointController,
      districtNumberController,
      letterController,
      uniqueNumberController,
      driverNameController,
      driverMobileController,
      numberOfTravelersController,
      stateTextController;
  int selectedStayStatus = 1;
  String vehicleType;
  String selectedStay;
  String selectedState;
  String selectedCheckpost;

  List<String> states = [];
  List<String> reserves = [];

  bool _isLoading = true;

  void initializeValues() async {
    selectedState = "1";
    selectedStay = '1';

    statess = Map<String, String>();
    checkPosts = Map<String, String>();
    reserveStays = Map<String, String>();
    dateController = TextEditingController();
    dateController.text = getFormattedDate(DateTime.now());
    entryTimeController = TextEditingController();
    entryTimeController.text = getFormattedTime(DateTime.now());
    ticketNumberController = TextEditingController();
    checkPointController = TextEditingController();
    districtNumberController = TextEditingController();
    letterController = TextEditingController();
    uniqueNumberController = TextEditingController();
    driverNameController = TextEditingController();
    driverMobileController = TextEditingController();
    numberOfTravelersController = TextEditingController();
    stateTextController = TextEditingController();
    ticketNumberController.text = await getTicketNumber();
    ticketVM = TicketViewModel(accessToken);
    checkPostVM = CheckPostViewModel(accessToken);
    checkPointController.text = checkPost;
    //  availableStates = await ticketVM.getStatesList();
    //  availableReserves = await ticketVM.getReserveStayList();
    // availableCheckPosts = await checkPostVM.getCheckPostList();
    // if (availableReserves.isNotEmpty) {
    //   for (var reserve in availableReserves) {
    //     reserves.add(reserve.name);
    //   }
    // }

    for (var reserveStay in availableReserves) {
      reserveStays.putIfAbsent(reserveStay.id, () => reserveStay.locationName);
    }

    for (var state in availableStates) {
      statess.putIfAbsent(state.id, () => state.name);
    }
    for (var checkPost in availableCheckPost) {
      checkPosts.putIfAbsent(checkPost.id, () => checkPost.name);
    }
    for (var v in availableCheckPost) {
      if (v.name == checkPost) {
        selectedCheckpost = v.id;
        break;
      }
    }
    // if (checkPosts.isNotEmpty) {
    //   selectedCheckpost = checkPosts.keys
    //       .firstWhere((element) => checkPosts[element] == checkPost);
    // }

    _isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    initializeValues();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToWidget());
  }

  scrollToWidget() async {
    await Future.delayed(Duration(milliseconds: 300));
    Scrollable.ensureVisible(scrollKey.currentContext);
  }

  Future printReceipt(EntryTicketModel ticket) async {
    Map<String, dynamic> data = {
      'Name': ticket.vehicle.driverName,
      'time': getFormattedTime(DateTime.parse(ticket.entryTime).toLocal()),
      'number': ticket.ticketNumber,
      'phone': ticket.vehicle.driverPhone,
      'checkPost': ticket.exitCheckPoint,
      'isFineTicket': false,
      'ticketMap': ticket.toJson()
    };
    final a = ticket.toJson();

    final result = await printer.printReceipt(data);
    return result;
  }

  Future<void> selectPrinter() async {
    final result = await printer.selectPrinter();
  }

  isTicketValid() {
    if (districtNumberController.text.isEmpty ||
        letterController.text.isEmpty ||
        uniqueNumberController.text.isEmpty ||
        vehicleType.isEmpty ||
        driverNameController.text.isEmpty ||
        driverMobileController.text.isEmpty) {
      return false;
    }
    return true;
  }

  saveTicket() async {
    // final printStatus = await printer.getPrinterStatus();
    // if (printStatus == 3) {
    if (isTicketValid()) {
      setState(() {
        _isLoading = true;
      });
      // final list = json.decode(result) as List;
      // if (result == null || list.isEmpty) {
      //   showSnackbar(_scaffoldKey, "No Printers found");
      // } else {
      //   print(result);
      // }

      final ticket = EntryTicketModel(
          numberOfTravelers: numberOfTravelersController.text,
          stayStatus: selectedStayStatus == 0 ? selectedStay : null,
          ticketNumber: ticketNumberController.text,
          entryCheckPoint: selectedCheckpost,
          keeperID: userId,
          fine: [],
          totalfine: "0",
          date: DateTime.now().toUtc().toString(),
          entryTime: DateTime.now().toUtc().toString(),
          hasExited: false,
          vehicle: Vehicle(
              driverName: driverNameController.text,
              districtCode: districtNumberController.text,
              driverPhone: driverMobileController.text,
              series: letterController.text,
              state: selectedState,
              type: vehicleType,
              uniqueNumber: uniqueNumberController.text));
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setInt(
          'ticketNumber', preferences.getInt('ticketNumber') + 1);

      ticketCollectorDao.insert(ticket);

      if (!isDeviceOnline) {
        await entryDao.insert(ticket);
      } else {
        try {
          final response =
              await ticketVM.saveTicket(ticket).timeout(TimeOutDuration);
          if (!response.didSucceed) {
            showSnackbar(_scaffoldKey, "Failed, Please try again.");
            setState(() {
              _isLoading = false;
            });
            return;
          }
        } on TimeoutException catch (_) {
          await entryDao.insert(ticket);
        }
      }
      setState(() {
        _isLoading = false;
      });
      printReceipt(ticket);
      Navigator.pop(context);
    } else {
      showSnackbar(_scaffoldKey, "Please enter all the required values");
      print(printerStatus);
    }
    // } else {
    //   showSnackbar(_scaffoldKey, "Please connect printer first");
    // }
  }

  Printer printer;

  @override
  Widget build(BuildContext context) {
    setState(() {});
    printer = Printer();
    return Scaffold(
      backgroundColor: BrtWhite,
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: GlobalScreenPadding,
                child: Column(
                  children: [
                    TicketInformationSection(
                        isFineScreen: false,
                        objectList: checkPosts,
                        title: "Enter entry Ticket Details",
                        dropDownTitle: "Select Check Point",
                        onSelected: (value) {
                          selectedCheckpost = checkPosts.keys.firstWhere(
                              (element) => checkPosts[element] == value);
                          setState(() {});
                        }, //checkPost ,
                        selectedCheckPost: selectedCheckpost,
                        dateController: dateController,
                        entryTimeController: entryTimeController,
                        ticketNumberController: ticketNumberController,
                        checkPointController: checkPointController),
                    widgetSeperator(),
                    widgetSeperator(),
                    VehicleNumberSection(
                        key: scrollKey,
                        onSelected: (value) {
                          selectedState = statess.keys.firstWhere(
                              (element) => statess[element] == value);
                          setState(() {});
                        },
                        selectedState: selectedState,
                        objectList: statess,
                        districtNumberController: districtNumberController,
                        letterController: letterController,
                        uniqueNumberController: uniqueNumberController),
                    widgetSeperator(),
                    VehicleSelectionSection(
                      vehicleType: vehicleType,
                      onChanged: (value) {
                        vehicleType = value;
                        setState(() {});
                      },
                    ),
                    widgetSeperator(),
                    DriverDetailsSection(
                        driverNameController: driverNameController,
                        driverMobileController: driverMobileController),
                    widgetSeperator(),
                    TravellerDetailsSection(
                        numberOfTravelersController:
                            numberOfTravelersController),
                    widgetSeperator(),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Stay Details",
                                style: SubHeadingTextStyle,
                              ),
                              widgetSeperator(),
                              BRTfieldhead("Staying in BR hills?"),
                              Row(
                                children: List.generate(
                                    yesOrNo.length,
                                    (index) => Row(
                                          children: [
                                            Radio(
                                                value: yesOrNo[index],
                                                groupValue:
                                                    yesOrNo[selectedStayStatus],
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedStayStatus =
                                                        yesOrNo.indexOf(value);
                                                  });
                                                  if (selectedStayStatus == 0) {
                                                    selectedStay = "1";
                                                  } else {
                                                    selectedStay = null;
                                                  }
                                                  setState(() {});
                                                }),
                                            Text(yesOrNo[index])
                                          ],
                                        )),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    selectedStayStatus == 0
                        ? StayDetailSection(
                            objectList: reserveStays,
                            selectedStay: selectedStay,
                            onSelected: (value) {
                              selectedStay = reserveStays.keys.firstWhere(
                                  (element) => reserveStays[element] == value);
                              setState(() {});
                            },
                          )
                        : Container(),
                    widgetSeperator(),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 20, vertical: 20),
                    //   child:
                    //       BrtButton(title: "Select", onPressed: selectPrinter),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: BrtButton(
                          title: "Print Ticket", onPressed: saveTicket),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

// class StayDetailSection extends StatefulWidget {
//   final String selectedStayStatus;
//   final Function onSelected;
//   final String selectedItem;
//   StayDetailSection(
//       {this.selectedStayStatus, this.onSelected, this.selectedItem});
//   @override
//   _StayDetailSectionState createState() => _StayDetailSectionState();
// }

// class _StayDetailSectionState extends State<StayDetailSection> {
//   @override
//   Widget build(BuildContext context) {
//     return widget.selectedStayStatus == '0'
//         ? BRTDropDownMenu(
//             items: [],
//             onSelected: widget.onSelected,
//             selectedItem: widget.selectedItem,
//             title: "Select location",
//           )
//         : Container();
//   }
// }

class StayDetailSection extends StatefulWidget {
  StayDetailSection({
    this.selectedStay,
    this.objectList,
    this.onSelected,
  });

  final Function onSelected;
//  final List<dynamic> objectList;
  final Map<String, dynamic> objectList;
  String selectedStay;

  @override
  _StayDetailSectionState createState() => _StayDetailSectionState();
}

class _StayDetailSectionState extends State<StayDetailSection> {
  List<String> states = [];
  Map<String, String> statess = Map();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            BRTDropDownMenu(
              items: widget.objectList.values.toList(),
              title: "Select location",
              onSelected: widget.onSelected,
              selectedItem: widget.objectList[widget.selectedStay],
            ),
          ],
        ),
      ],
    );
  }
}

//
//                             ? BRTDropDownMenu(
//                                 items: reserveStays.values.toList(),
//                                 onSelected: (value) {
//                                   selectedStay = reserveStays.keys.firstWhere(
//                                       (element) =>
//                                           reserveStays[element] == value);
//                                   setState(() {});
//                                 },
//                                 selectedItem: selectedStay,
//                                 title: "Select location",
//                               )
//                             : Container(),
