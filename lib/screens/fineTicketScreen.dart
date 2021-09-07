import 'dart:async';

import 'package:BRT/constants.dart';
import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/models/fine.dart';

import 'package:BRT/models/vehicle.dart';
import 'package:BRT/services/printer.dart';
import 'package:BRT/services/utilityFunctions.dart';
import 'package:BRT/services/variables.dart';
import 'package:BRT/viewmodels/ticketviewmodel.dart';
import 'package:BRT/widgets/brtFormfield.dart';
import 'package:BRT/widgets/brtbutton.dart';
import 'package:BRT/widgets/iconcontainer.dart';
import 'package:BRT/widgets/ticketInfoForm.dart';
import 'package:BRT/widgets/ticketformwidgets/driverinfosection.dart';
import 'package:BRT/widgets/ticketformwidgets/vehiclenumbersection.dart';
import 'package:BRT/widgets/ticketformwidgets/vehiclesection.dart';
import 'package:BRT/widgets/utilityWidgets.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../strings.dart';

class FineTicket extends StatefulWidget {
  @override
  _FineTicketState createState() => _FineTicketState();
}

class _FineTicketState extends State<FineTicket> {
  ScrollController scrollController = ScrollController();
  int sc = 0;

  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  TicketViewModel ticketVM;
  Map<String, dynamic> statess;
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
      stateTextController,
      fineController;
  int selectedStayStatus = 0;
  String vehicleType;
  String selectedFine;
  bool _isLoading = true;
  String selectedState = "1";
  List<bool> violationCheckStatus = [];
  List<String> selectedViolations = [];

  void initializeValues() async {
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
    fineController = TextEditingController();
    ticketNumberController.text = await getTicketNumber();
    ticketVM = TicketViewModel(accessToken);

    statess = Map<String, String>();
    for (var v in fines) {
      violationCheckStatus.add(false);
    }

    for (var state in availableStates) {
      statess.putIfAbsent(state.id, () => state.name);
    }
    _isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    initializeValues();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          sc = 1;
        });
      }
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        setState(() {
          sc = 0;
        });
      }
    });
    super.initState();
  }

  saveFineTicket() async {
    setState(() {
      _isLoading = true;
    });
    // fineList.add(Fine(
    //   fineamout: fineController.text,
    //   fineId: [fineID[fines.indexOf(selectedFine) - 1] + 1].toString(),
    // ));
    final ticket = EntryTicketModel(
        ticketNumber: ticketNumberController.text,
        date: DateTime.now().toUtc().toString(),
        keeperID: userId,
        entryTime: DateTime.now().toUtc().toString(),
        totalfine: 0.0,
        vehicle: Vehicle(
            driverName: driverNameController.text,
            districtCode: districtNumberController.text,
            driverPhone: driverMobileController.text,
            series: letterController.text,
            state: selectedState,
            type: vehicleType,
            uniqueNumber: uniqueNumberController.text),
        fine: [
          Fine(
            fineamout: fineController.text,
            //   ticketId: ticketNumberController.text,
            fineId:
                selectedViolations, //fineID[fines.indexOf(selectedFine)].toString(),
          ),
        ]);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('ticketNumber', preferences.getInt('ticketNumber') + 1);
    //fineId: fineID[    fines.indexOf(selectedFine)                 ]);

    if (!isDeviceOnline) {
      fineDao.insert(ticket);
      printReceipt(ticket);
      setState(() {
        _isLoading = false;
      });
      showSnackbar(_scaffoldKey, "Ticket Generated");
      // Navigator.pop(context);

      // final List a = await dao.getAllEntryTickets();
      // for (var ticket in a) {
      //   await ticketVM.saveTicket(ticket);
      //   dao.remove(ticket);
      // }
    } else {
      try {
        final response =
            await ticketVM.saveFineTicket(ticket).timeout(TimeOutDuration);
        if (response.didSucceed) {
          printReceipt(ticket);
          Navigator.pop(context);
        } else
          setState(() {
            _isLoading = false;
          });
        showSnackbar(_scaffoldKey, "Failed, Please try again.");
      } on TimeoutException catch (_) {
        print(_);
      }
    }
  }

  Future<void> printReceipt(EntryTicketModel ticket) async {
    String violations = "";
    for (int i = 0; i < selectedViolations.length; i++) {
      violations += getViolationById(int.parse(selectedViolations[i]));
      if (i == selectedViolations.length - 1) {
        violations += ".";
      } else {
        violations += ",";
      }
    }
    Map<String, dynamic> data = {
      'Name': ticket.vehicle.driverName,
      // 'time': ticket.entryTime,
      'number': ticket.ticketNumber,
      'phone': ticket.vehicle.driverPhone,
      'checkPost': checkPost,
      'fine': ticket.fine[0].fineamout,
      'time': entryTimeController.text,
      // 'fine':getAllFine(ticket.fine),
      'violation': violations,
      'isFineTicket': true
    };

    //

    final result = await printer.printReceipt(data);
  }

  Future<void> selectPrinter() async {
    final result = await printer.selectPrinter();
  }

  Printer printer;

  @override
  Widget build(BuildContext context) {
    printer = Printer();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Brtblack,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: GlobalScreenPadding.copyWith(top: 0),
                child: Column(
                  children: [
                    TicketInformationSection(
                        title: "Enter fine ticket details",
                        isFineScreen: true,
                        dateController: dateController,
                        entryTimeController: entryTimeController,
                        ticketNumberController: ticketNumberController,
                        checkPointController: checkPointController),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    VehicleNumberSection(
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    VehicleSelectionSection(
                      vehicleType: vehicleType,
                      onChanged: (value) {
                        vehicleType = value;
                        setState(() {});
                      },
                    ),
                    widgetSeperator(),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Violation",
                            style: SubHeadingTextStyle,
                          ),
                          widgetSeperator(),
                          Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                // height:
                                //     MediaQuery.of(context).size.height * 0.23,
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                        fines.length,
                                        (index) => Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: BRTCheckBox(
                                                icon: fineIcons[index],
                                                isSelected:
                                                    violationCheckStatus[index],
                                                onChanged: (isSelected) {
                                                  if (isSelected) {}
                                                  setState(() {
                                                    violationCheckStatus[
                                                            index] =
                                                        isSelected
                                                            ? false
                                                            : true;
                                                    String selected = fineID[
                                                            fines.indexOf(
                                                                fines[index])]
                                                        .toString();

                                                    if (selectedViolations
                                                        .contains(selected)) {
                                                      selectedViolations
                                                          .remove(selected);
                                                    } else {
                                                      selectedViolations
                                                          .add(selected);
                                                    }
                                                  });
                                                },
                                                title: fines[index],
                                              ),
                                            )),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: sc == 0
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      color: Colors.white.withOpacity(0.2),
                                      height: 120,
                                      width: 30,
                                      child: Center(
                                          child: Icon(
                                        sc == 1
                                            ? Icons.arrow_back_ios
                                            : Icons.arrow_forward_ios,
                                        size: 40,
                                        color: Colors.green.withOpacity(0.3),
                                      )),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    DriverDetailsSection(
                        driverNameController: driverNameController,
                        driverMobileController: driverMobileController),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fine",
                          style: SubHeadingTextStyle,
                        ),
                        widgetSeperator(),
                        BrtFormField(
                          icon: Icons.payments,
                          textInputType: TextInputType.number,
                          title: "Fine amount",
                          controller: fineController,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    BrtButton(
                        title: "Save & Print Ticket", onPressed: saveFineTicket)
                  ],
                ),
              ),
            ),
    );
  }
}
