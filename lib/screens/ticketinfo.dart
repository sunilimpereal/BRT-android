import 'dart:async';
import 'package:BRT/constants.dart';
import 'package:BRT/main.dart';
import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/models/fine.dart';
import 'package:BRT/models/raiseFine.dart';
import 'package:BRT/models/vehicle.dart';
import 'package:BRT/repositories/entryTicketDao.dart';
import 'package:BRT/repositories/raisefineticketsDao.dart';
import 'package:BRT/services/printer.dart';
import 'package:BRT/services/utilityFunctions.dart';
import 'package:BRT/services/variables.dart';
import 'package:BRT/strings.dart';
import 'package:BRT/viewmodels/ticketviewmodel.dart';
import 'package:BRT/widgets/brtFormfield.dart';
import 'package:BRT/widgets/brtbutton.dart';
import 'package:BRT/widgets/dialogs.dart';
import 'package:BRT/widgets/iconcontainer.dart';
import 'package:BRT/widgets/titlesubtitle.dart';
import 'package:BRT/widgets/underlinebutton.dart';
import 'package:BRT/widgets/utilityWidgets.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

enum LinkType { Email, Phone }

class TicketInfoArguments {
  EntryTicketModel ticket;
  bool isQrScanned;
  TicketInfoArguments({this.ticket, this.isQrScanned = true});
}

class TicketInfoScreen extends StatefulWidget {
  final TicketInfoArguments arguments;
  TicketInfoScreen({this.arguments});
  @override
  _TicketInfoScreenState createState() => _TicketInfoScreenState();
}

class _TicketInfoScreenState extends State<TicketInfoScreen> {
  TicketViewModel ticketVM;
  bool _isLoading = false;
  String selectedFine;
  Key _scaffoldKey = GlobalKey<ScaffoldState>();
  Printer printer;
  TextEditingController fineController = TextEditingController();
  bool isFineError = false;
  List<bool> violationCheckStatus = [];
  List<String> selectedViolations = [];
  @override
  void initState() {
    for (var v in fines) {
      violationCheckStatus.add(false);
    }
    ticketVM = TicketViewModel(accessToken);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTicket();
    });
    super.initState();
  }

  Future<void> selectPrinter() async {
    final result = await printer.selectPrinter();
  }

  Future<EntryTicketModel> getTicket() async {
    try {
      //   final ticketNumber = widget.ticket.ticketNumber;
      //   connection = await (Connectivity().checkConnectivity());
      //   if (connection != ConnectivityResult.none) {
      //     final data = await ticketVM.getTicketByNumber(ticketNumber);
      //     qrStream.sink.add(data);
      //     return data;
      //  }
      //  else {
      final data = EntryTicketModel(
          date: widget.arguments.ticket.date,
          entryCheckPoint: widget.arguments.ticket.entryCheckPoint,
          entryTime: widget.arguments.ticket.entryTime,
          exitCheckPoint: widget.arguments.ticket.exitCheckPoint,
          exitTime: widget.arguments.ticket.exitTime,
          numberOfTravelers: widget.arguments.ticket.numberOfTravelers,
          hasExited: widget.arguments.ticket.hasExited,
          fine: widget.arguments.ticket.fine,
          // fine: [widget.ticketNumber['fine']],
          ticketNumber: widget.arguments.ticket.ticketNumber,
          stayStatus: widget.arguments.ticket.stayStatus,
          vehicle: Vehicle(
              driverName: widget.arguments.ticket.vehicle.driverName,
              driverPhone: widget.arguments.ticket.vehicle.driverPhone,
              state: widget.arguments.ticket.vehicle.state,
              series: widget.arguments.ticket.vehicle.series,
              type: widget.arguments.ticket.vehicle.type,
              districtCode: widget.arguments.ticket.vehicle.districtCode,
              uniqueNumber: widget.arguments.ticket.vehicle.uniqueNumber));
      qrStream.sink.add(data);
      return data;
      //  }
    } catch (_) {
      qrStream.sink.addError('failed');
    }
  }

  Future<void> markexit() async {
    setState(() {
      _isLoading = true;
    });

    if (!isDeviceOnline) {
      /// mark ticket as exited  locally
      EntryTicketDao entryDao = EntryTicketDao();
      final ticket = EntryTicketModel(
          exitTime: DateTime.now().toUtc().toString().replaceAll(' ', 'T'),
          ticketNumber: widget.arguments.ticket.ticketNumber,
          stayStatus: widget.arguments.ticket.stayStatus,
          numberOfTravelers: widget.arguments.ticket.numberOfTravelers,
          fine: widget.arguments.ticket.fine,
          date: widget.arguments.ticket.date.replaceAll(' ', 'T'),
          entryCheckPoint: widget.arguments.ticket.entryCheckPoint,
          entryTime: widget.arguments.ticket.entryTime.replaceAll(' ', 'T'),
          keeperID: userId,
          exitCheckPoint: availableCheckPost
              .firstWhere((element) => element.name == checkPost)
              .id,
          totalfine: 0.00,
          hasExited: true,
          vehicle: Vehicle(
              driverName: widget.arguments.ticket.vehicle.driverName,
              driverPhone: widget.arguments.ticket.vehicle.driverPhone,
              state: widget.arguments.ticket.vehicle.state,
              series: widget.arguments.ticket.vehicle.series,
              type: widget.arguments.ticket.vehicle.type,
              districtCode: widget.arguments.ticket.vehicle.districtCode,
              uniqueNumber: widget.arguments.ticket.vehicle.uniqueNumber));
      final int x = await entryDao.markExitOffline(ticket);
      print('saved ticket $x');
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
      return;
    } else {
      final ticket = EntryTicketModel(
          exitTime: DateTime.now().toUtc().toString().replaceAll(' ', 'T'),
          ticketNumber: widget.arguments.ticket.ticketNumber,
          stayStatus: widget.arguments.ticket.stayStatus,
          numberOfTravelers: widget.arguments.ticket.numberOfTravelers,
          fine: widget.arguments.ticket.fine,
          date: widget.arguments.ticket.date.replaceAll(' ', 'T'),
          entryCheckPoint: availableCheckPost
              .firstWhere((element) =>
                  element.name == widget.arguments.ticket.entryCheckPoint ||
                  element.id == widget.arguments.ticket.entryCheckPoint)
              .id,
          entryTime: widget.arguments.ticket.entryTime.replaceAll(' ', 'T'),
          keeperID: userId,
          exitCheckPoint: availableCheckPost
              .firstWhere((element) => element.name == checkPost)
              .id,
          totalfine: 0.00,
          hasExited: true,
          vehicle: Vehicle(
              driverName: widget.arguments.ticket.vehicle.driverName,
              driverPhone: widget.arguments.ticket.vehicle.driverPhone,
              state: widget.arguments.ticket.vehicle.state,
              series: widget.arguments.ticket.vehicle.series,
              type: widget.arguments.ticket.vehicle.type,
              districtCode: widget.arguments.ticket.vehicle.districtCode,
              uniqueNumber: widget.arguments.ticket.vehicle.uniqueNumber));
      try {
        final response =
            await ticketVM.updateTicket(ticket).timeout(TimeOutDuration);
        if (response.didSucceed) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        } else {
          setState(() {
            _isLoading = false;
          });
          showSnackbar(_scaffoldKey, "Error occured");
        }
      } on TimeoutException catch (_) {
        EntryTicketDao entryDao = EntryTicketDao();
        final ticket = EntryTicketModel(
            exitTime: DateTime.now().toUtc().toString().replaceAll(' ', 'T'),
            ticketNumber: widget.arguments.ticket.ticketNumber,
            stayStatus: widget.arguments.ticket.stayStatus,
            numberOfTravelers: widget.arguments.ticket.numberOfTravelers,
            fine: widget.arguments.ticket.fine,
            date: widget.arguments.ticket.date.replaceAll(' ', 'T'),
            entryCheckPoint: availableCheckPost
                .firstWhere((element) =>
                    element.name == widget.arguments.ticket.entryCheckPoint)
                .id,
            entryTime: widget.arguments.ticket.entryTime.replaceAll(' ', 'T'),
            keeperID: userId,
            exitCheckPoint: availableCheckPost
                .firstWhere((element) => element.name == checkPost)
                .id,
            totalfine: 0.00,
            hasExited: true,
            vehicle: Vehicle(
                driverName: widget.arguments.ticket.vehicle.driverName,
                driverPhone: widget.arguments.ticket.vehicle.driverPhone,
                state: widget.arguments.ticket.vehicle.state,
                series: widget.arguments.ticket.vehicle.series,
                type: widget.arguments.ticket.vehicle.type,
                districtCode: widget.arguments.ticket.vehicle.districtCode,
                uniqueNumber: widget.arguments.ticket.vehicle.uniqueNumber));
        final int x = await entryDao.markExitOffline(ticket);
        print('saved ticket $x');
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
        return;
      }
    }
  }

  Widget openFineMenu() {
    print("Pressed");
    return Dialog(
      child: Container(
        height: 20,
        width: 20,
        color: Colors.red,
      ),
    );
  }

  final qrStream = StreamController<EntryTicketModel>.broadcast();

  @override
  void dispose() {
    // TODO: implement dispose
    qrStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printer = Printer();
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : StreamBuilder<EntryTicketModel>(
                stream: qrStream.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<EntryTicketModel> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Invalid QR code, Redirecting"),
                    );
                  } else if (snapshot.data == null) {
                    return Center(child: CircularProgressIndicator());
                  } else
                    return Padding(
                      padding: GlobalScreenPadding,
                      child: ListView(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TicketNumberStatusSection(
                                ticketNumber: snapshot.data.ticketNumber,
                                exitCheckPost: snapshot.data.exitCheckPoint,

                                //status: snapshot.data.status ?? "-",
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: DriverInfoCard(
                                  name: snapshot.data.vehicle.driverName,
                                  phoneNumber:
                                      snapshot.data.vehicle.driverPhone,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: TicketDetailSection(
                                    date: snapshot.data.date,
                                    ticketNumber: snapshot.data.ticketNumber,
                                    entryCheckPost: snapshot.data.entryCheckPoint != null
                                        ? availableCheckPost
                                            .firstWhere((element) =>
                                                element.name == snapshot.data.entryCheckPoint ||
                                                element.id ==
                                                    snapshot
                                                        .data.entryCheckPoint)
                                            .name
                                        : "-",
                                    exitCheckPost: snapshot.data.exitCheckPoint != null
                                        ? availableCheckPost
                                            .firstWhere((element) =>
                                                element.name == snapshot.data.exitCheckPoint ||
                                                element.id ==
                                                    snapshot
                                                        .data.exitCheckPoint)
                                            .name
                                        : "-",
                                    entryTime:
                                        DateTime.parse(snapshot.data.entryTime)
                                            .toLocal()
                                            .toString(),
                                    exitTime: snapshot.data.exitTime != null
                                        ? getFormattedTime(DateTime.parse(snapshot.data.exitTime).toLocal())
                                        : "-"),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: VehicleNumberSection(
                                  districtNumber:
                                      snapshot.data.vehicle.districtCode,
                                  uniqueNumber:
                                      snapshot.data.vehicle.uniqueNumber,
                                  state: snapshot.data.vehicle.state,
                                  letters: snapshot.data.vehicle.series,
                                  vehicleType: snapshot.data.vehicle.type,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: TravellerInfoCard(
                                  numberOfTravellers:
                                      snapshot.data.numberOfTravelers,
                                  stayDetail: snapshot.data.stayStatus != null
                                      ? availableReserves
                                          .firstWhere((element) =>
                                              element.id ==
                                              snapshot.data.stayStatus
                                                  .toString())
                                          .locationName
                                      : "No",
                                ),
                              ),
                              widget.arguments.isQrScanned
                                  ? Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: snapshot.data.exitTime != null
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                BrtButton(
                                                    title: snapshot.data
                                                                .exitTime !=
                                                            null
                                                        ? "Exited"
                                                        : "Mark as exit",
                                                    buttonColor: snapshot.data
                                                                .exitTime ==
                                                            null
                                                        ? BRTbrown
                                                        : BrtdisabledBrown,
                                                    onPressed: () {
                                                      /// if not exited
                                                      if (snapshot
                                                              .data.exitTime ==
                                                          null) {
                                                        markexit();
                                                      }
                                                    })
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                UnderLineButton(
                                                  "Raise Fine",
                                                  onTap: () {
                                                    showFineDialog(
                                                        context, snapshot.data);
                                                  },
                                                ),
                                                BrtButton(
                                                    title: snapshot.data
                                                                .exitTime !=
                                                            null
                                                        ? "Exited"
                                                        : "Mark as exit",
                                                    buttonColor: snapshot.data
                                                                .exitTime ==
                                                            null
                                                        ? BRTbrown
                                                        : BrtdisabledBrown,
                                                    onPressed: () {
                                                      if (snapshot
                                                              .data.exitTime ==
                                                          null) {
                                                        markexit();
                                                      }
                                                    })
                                              ],
                                            ),
                                    )
                                  : Container()
                            ],
                          ),
                        ],
                      ),
                    );
                }));
  }

  printFineTicket(EntryTicketModel ticket) async {
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
      'time': ticket.entryTime,
      'number': ticket.ticketNumber,
      'phone': ticket.vehicle.driverPhone,
      'checkPost': checkPost,
      'fine': fineController.text,
      'violation': violations,
      // 'fine': ticket.fine.fineamout,
      'isFineTicket': true
    };

    //

    final result = await printer.printReceipt(data);
  }

  Future showFineDialog(BuildContext context, EntryTicketModel ticket) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return StatefulBuilder(builder: (context, setState) {
            return DialogSheet(SingleChildScrollView(
              child: Container(
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Raise Fine",
                              style: SubHeadingTextStyle,
                            ),
                            GestureDetector(
                              onTap: () {
                                selectedFine = "";
                                fineController.clear();
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.close),
                            )
                          ],
                        ),
                      ),
                      widgetSeperator(),
                      Center(
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          childAspectRatio: (MediaQuery.of(context).size.width /
                                  MediaQuery.of(context).size.height) *
                              1.2,
                          physics: NeverScrollableScrollPhysics(),
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
                                            selectedViolations.remove(selected);
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
                      ),
                      widgetSeperator(),
                      BrtFormField(
                          title: "Enter fine amount",
                          textInputType: TextInputType.number,
                          controller: fineController),
                      isFineError
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                "Unable to raise fine. Please Try again.",
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(),
                            GestureDetector(
                              onTap: () async {
                                if (fineController.text.isNotEmpty &&
                                    fineController.text != null) {
                                  final fineTicket = RaisedFineModel(
                                      fine: [
                                        Fine(
                                          fineId: selectedViolations,
                                          fineamout: fineController.text,
                                        )
                                      ],
                                      ticketNumber:
                                          widget.arguments.ticket.ticketNumber);

                                  if (!isDeviceOnline) {
                                    //   RaiseFineDao().insert(fineTicket);
                                    final tickets = EntryTicketModel(
                                        numberOfTravelers:
                                            ticket.numberOfTravelers,
                                        ticketNumber: ticket.ticketNumber,
                                        entryTime: getFormattedTime(
                                            DateTime.parse(ticket.entryTime)
                                                .toLocal()),
                                        vehicle: ticket.vehicle,
                                        fine: [
                                          Fine(
                                              fineamout: fineController.text,
                                              ticketId: ticket.ticketNumber,
                                              fineId: selectedViolations),
                                        ]);
                                    raisedFineDao.insert(fineTicket);
                                    ticketCollectorDao
                                        .raiseFineOffline(fineTicket);
                                    printFineTicket(tickets);
                                    Navigator.pop(context);
                                    showSnackbar(_scaffoldKey, "Fine Raised");
                                    return;
                                  }
                                  try {
                                    final response = await ticketVM
                                        .raiseFine(fineTicket)
                                        .timeout(TimeOutDuration);
                                    if (response.didSucceed) {
                                      final ticket = await getTicket();
                                      printFineTicket(ticket);
                                      Navigator.pop(context);
                                      showSnackbar(_scaffoldKey, "Fine Raised");
                                    } else {
                                      setState(() {
                                        isFineError = true;
                                      });
                                    }
                                  } on TimeoutException catch (_) {
                                    final tickets = EntryTicketModel(
                                        numberOfTravelers:
                                            ticket.numberOfTravelers,
                                        ticketNumber: ticket.ticketNumber,
                                        entryTime: getFormattedTime(
                                            DateTime.parse(ticket.entryTime)
                                                .toLocal()),
                                        vehicle: ticket.vehicle,
                                        fine: [
                                          Fine(
                                              fineamout: fineController.text,
                                              ticketId: ticket.ticketNumber,
                                              fineId: selectedViolations),
                                        ]);
                                    raisedFineDao.insert(fineTicket);
                                    printFineTicket(tickets);
                                    Navigator.pop(context);
                                    showSnackbar(_scaffoldKey, "Fine Raised");
                                    return;
                                  }
                                }
                              },
                              child: Text(
                                "Save Fine",
                                style: headingTextStyle,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
          });
        });
  }
}

class TicketNumberStatusSection extends StatelessWidget {
  TicketNumberStatusSection({this.exitCheckPost, this.ticketNumber});
  final String ticketNumber;
  final String exitCheckPost;

  @override
  Widget build(BuildContext context) {
    bool isExited = exitCheckPost != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Entry Ticket number $ticketNumber",
          style: headingTextStyle,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              isExited ? Icon(Icons.time_to_leave) : Container(),
              SizedBox(
                width: 15,
              ),
              Text(
                isExited
                    ? "Vehicle has exited BR hills"
                    : "Vehicle is in BR hills",
                style: TextStyle(color: isExited ? BrtGreen : BrtYellow),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class DriverInfoCard extends StatelessWidget {
  DriverInfoCard({this.name, this.phoneNumber});
  final String name;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name ?? "-", style: TextStyle(fontSize: 20, color: Brtblack)),
            SizedBox(
              height: 10,
            ),
            Text(
              phoneNumber,
              style: TextStyle(color: Brtblack),
            ),
          ]),
        ),
        GestureDetector(
          onTap: () {
            launchURL(phoneNumber, linkType: LinkType.Phone);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(assetsDirectory + "ContactIcon.png"),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Call Now",
                  style: TextStyle(color: BRTbrown),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VehicleNumberSection extends StatelessWidget {
  VehicleNumberSection(
      {this.state,
      this.districtNumber,
      this.letters,
      this.uniqueNumber,
      this.vehicleType,
      this.imageIcon});
  final String state;
  final String districtNumber;
  final String letters;
  final String uniqueNumber;
  final String vehicleType;
  final String imageIcon;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead("Vehicle number"),
        TitleSubtitleView(
          title: "State",
          subtitle: availableStates
                  .firstWhere((element) => element.id == state)
                  .name ??
              "-",
        ),
        Row(
          children: [
            Expanded(
                flex: 2,
                child: TitleSubtitleView(
                  title: "District Number",
                  subtitle: districtNumber ?? "-",
                )),
            Expanded(
                flex: 1,
                child: TitleSubtitleView(
                  title: "Letters",
                  subtitle: letters ?? "-",
                )),
            Expanded(
                flex: 2,
                child: TitleSubtitleView(
                  title: "Unique Number",
                  subtitle: uniqueNumber ?? "-",
                ))
          ],
        ),
        SizedBox(
          height: 20,
        ),
        SectionHead("Vehicle Type"),
        IconContainerr(
          title: vehicleType,
        ),
      ],
    );
  }
}

class IconContainerr extends StatelessWidget {
  IconContainerr({this.title, this.imageIcon});
  final String title;
  final String imageIcon;

  @override
  Widget build(BuildContext context) {
    String getIcon(title) {
      if (vehicles.contains(title)) {
        return vehicleIcons[vehicles.indexOf(title)];
      }
      return vehicleIcons[0];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
                color: BRTlightBrown, borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.all(20),
            child: Center(
              child: Image.asset(assetsDirectory + getIcon(title)),
            ),
          ),
          Container(
            child: Text(
              title ?? "",
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}

class TravellerInfoCard extends StatelessWidget {
  TravellerInfoCard({this.numberOfTravellers, this.stayDetail});
  final String numberOfTravellers;
  final String stayDetail;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead("Travellers details"),
        TitleSubtitleView(
          title: "Number of travellers",
          subtitle: numberOfTravellers ?? "-",
        ),
        SectionHead("Stay Details"),
        TitleSubtitleView(
          title: "Staying in BR hills",
          subtitle: stayDetail ?? "-",
        ),
      ],
    );
  }
}

class TicketDetailSection extends StatelessWidget {
  TicketDetailSection({
    this.date,
    this.entryCheckPost,
    this.entryTime,
    this.exitCheckPost,
    this.exitTime,
    this.ticketNumber,
  });
  final String date;
  final String entryTime;
  final String exitTime;
  final String ticketNumber;
  final String entryCheckPost;
  final String exitCheckPost;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead("Ticket Information"),
        TitleSubtitleView(
          title: "Date",
          subtitle: getFormattedDate(DateTime.parse(date)).toString() ?? "-",
        ),
        Row(
          children: [
            Expanded(
              child: TitleSubtitleView(
                title: "Entry time",
                subtitle: getFormattedTime(DateTime.parse(entryTime)) ?? "-",
              ),
            ),
            Expanded(
              child: TitleSubtitleView(
                title: "Exit time",
                subtitle: exitTime ?? "-",
              ),
            ),
          ],
        ),
        TitleSubtitleView(
          title: "Ticket Number",
          subtitle: ticketNumber ?? "-",
        ),
        TitleSubtitleView(
          title: "Entry checkpost",
          subtitle: entryCheckPost,
        ),
        TitleSubtitleView(
          title: "Exit checkpost",
          subtitle: exitCheckPost ?? "-",
        ),
      ],
    );
  }
}

class SectionHead extends StatelessWidget {
  final String title;
  SectionHead(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 17, color: BrtGray),
    );
  }
}
