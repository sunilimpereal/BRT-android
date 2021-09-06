import 'dart:async';

import 'package:BRT/constants.dart';
import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/models/fine.dart';
import 'package:BRT/models/states.dart';
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
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../strings.dart';

class FineTicket extends StatefulWidget {
  @override
  _FineTicketState createState() => _FineTicketState();
}

class _FineTicketState extends State<FineTicket> {
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
      Navigator.pop(context);

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
                padding: GlobalScreenPadding,
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
                      height: MediaQuery.of(context).size.height * 0.05,
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
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    VehicleSelectionSection(
                      vehicleType: vehicleType,
                      onChanged: (value) {
                        vehicleType = value;
                        setState(() {});
                      },
                    ),
                    // Wrap(
                    //   children: [
                    //     FilterChip(
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10)),
                    //       padding: EdgeInsets.symmetric(
                    //           vertical: 10, horizontal: 10),
                    //       label: Column(
                    //         children: [
                    //           Image.asset(assetsDirectory + fineIcons[0]),
                    //           Padding(
                    //             padding: const EdgeInsets.all(8.0),
                    //             child: Text("OverStaying"),
                    //           ),
                    //         ],
                    //       ),
                    //       onSelected: (isSelected) {},
                    //     )
                    //   ],
                    // ),

                    DriverDetailsSection(
                        driverNameController: driverNameController,
                        driverMobileController: driverMobileController),
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Violation",
                            style: SubHeadingTextStyle,
                          ),
                          widgetSeperator(),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),

                            childAspectRatio:
                                (MediaQuery.of(context).size.width /
                                    MediaQuery.of(context).size.height),

                            //crossAxisAlignment: WrapCrossAlignment.start,
                            children: List.generate(
                                fines.length,
                                (index) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: BRTCheckBox(
                                        icon: fineIcons[index],
                                        isSelected: violationCheckStatus[index],
                                        onChanged: (isSelected) {
                                          if (isSelected) {}
                                          setState(() {
                                            violationCheckStatus[index] =
                                                isSelected ? false : true;
                                            String selected = fineID[
                                                    fines.indexOf(fines[index])]
                                                .toString();

                                            if (selectedViolations
                                                .contains(selected)) {
                                              selectedViolations
                                                  .remove(selected);
                                            } else {
                                              selectedViolations.add(selected);
                                            }
                                          });
                                        },
                                        title: fines[index],
                                      ),
                                      // child: IconContainer(
                                      //   title: fines[index],
                                      //   groupValue: selectedFine,
                                      //   icon: fineIcons[index],
                                      //   value: fines[index],
                                      //   onChnaged: (value) {
                                      //     selectedFine = value;
                                      //     setState(() {});
                                      //   },
                                      // ),
                                    )),
                          ),
                        ],
                      ),
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
                        )
                      ],
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

// class BRTRadios extends StatelessWidget {
//   BRTRadios({this.onChanged, this.titleList, this.iconList, this.groupValue});

//   final Function onChanged;
//   final dynamic groupValue;
//   final List<String> titleList;
//   final List<String> iconList;

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       children: List.generate(
//         titleList.length,
//         (index) => Column(
//           children: [
//             Container(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Image.asset(assetsDirectory + iconList[index]),
//                   Row(
//                     children: [
//                       Radio(
//                           value: titleList[index],
//                           groupValue: groupValue,
//                           onChanged: onChanged),
//                       Expanded(child: Text(titleList[index])),
//                     ],
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
