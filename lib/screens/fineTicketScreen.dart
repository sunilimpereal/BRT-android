import 'dart:async';
import 'dart:io';

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

import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
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
      fineController,
      utrNumberController;
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
    utrNumberController = TextEditingController();
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

  // File _image;

  // File _camera;

  // Future getImage() async {
  //   final image = await ImagePicker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     _image = image;
  //   });
  // }

  // Future getCamera() async {
  //   final camera = await ImagePicker().getImage(source: ImageSource.camera);
  //   // setState(() {
  //   //   _camera = camera;
  //   // });
  // }

  var _image;
  Future getImage(ImgSource source) async {
    var image = await ImagePickerGC.pickImage(
        // enableCloseButton: true,
        // closeIcon: Icon(
        //   Icons.close,
        //   color: Colors.red,
        //   size: 12,
        // ),
        context: context,
        source: source,
        barrierDismissible: true,
        cameraIcon: Icon(Icons.camera_alt, color: Colors.orange),
        galleryIcon: Icon(
          Icons.photo,
          color: Colors.green,
        ), //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
        cameraText: Text(
          "From Camera",
          style: TextStyle(color: Colors.black),
        ),
        galleryText: Text(
          "From Gallery",
          style: TextStyle(color: Colors.black),
        ));
    setState(() {
      _image = image;
    });
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
            utrId: utrNumberController.text == ''
                ? null
                : utrNumberController.text,
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
      'date': dateController.text,
      // 'fine':getAllFine(ticket.fine),
      'violation': violations,
      'isFineTicket': true,
      'utrId':ticket.fine[0].utrId
    };

    //

    final result = await printer.printReceipt(data);
  }

  Future<void> selectPrinter() async {
    final result = await printer.selectPrinter();
  }

  Printer printer;
  bool payment = false;

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
                          Container(
                              width: MediaQuery.of(context).size.width,
                              // height:
                              //     MediaQuery.of(context).size.height * 0.23,
                              child: GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),

                                childAspectRatio:
                                    (MediaQuery.of(context).size.width /
                                        MediaQuery.of(context).size.height *
                                        1.25),

                                //crossAxisAlignment: WrapCrossAlignment.start,
                                children: List.generate(
                                    fines.length,
                                    (index) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: BRTCheckBox(
                                            icon: fineIcons[index],
                                            isSelected:
                                                violationCheckStatus[index],
                                            onChanged: (isSelected) {
                                              if (isSelected) {}
                                              setState(() {
                                                violationCheckStatus[index] =
                                                    isSelected ? false : true;
                                                String selected = fineID[fines
                                                        .indexOf(fines[index])]
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
                              )),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BrtButton(
                            title: "Image",
                            onPressed: () => getImage(ImgSource.Both)),

                        // BrtButton(title: "camera", onPressed: ),
                      ],
                    ),
                    widgetSeperator(),
                    widgetSeperator(),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Payment",
                              style: SubHeadingTextStyle,
                            ),
                            Checkbox(
                              value: payment,
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                              onChanged: (value) {
                                setState(() {
                                  payment = value;
                                });
                              },
                            )
                          ],
                        ),
                        widgetSeperator(),
                        payment
                            ? BrtFormField(
                                textInputType: TextInputType.number,
                                title: "UTR Number",
                                controller: utrNumberController,
                              )
                            : Container(),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    BrtButton(
                        title: "Save & Print Ticket",
                        onPressed: saveFineTicket),
                  ],
                ),
              ),
            ),
    );
  }
}
