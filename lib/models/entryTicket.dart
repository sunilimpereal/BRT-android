import 'dart:convert';

import 'package:BRT/models/fine.dart';
import 'package:BRT/models/reservestay.dart';
import 'package:BRT/models/vehicle.dart';

class EntryTicketModel {
  String ticketNumber;
  String keeperID;
  ReserveStay reserveStay;
  Vehicle vehicle;
  String numberOfTravelers;
  dynamic totalfine;
  List<Fine> fine;
  dynamic stayStatus;
  String entryCheckPoint;
  String exitCheckPoint;
  String entryTime;
  String exitTime;
  String date;
  String createdDtTm;
  bool hasExited;
  EntryTicketModel(
      {this.ticketNumber,
      this.vehicle,
      this.numberOfTravelers,
      this.stayStatus,
      this.date,
      this.entryCheckPoint,
      this.exitCheckPoint,
      this.entryTime,
      this.exitTime,
      this.totalfine,
      this.hasExited,
      this.keeperID,
      this.fine});

  Map<String, dynamic> toMap() {
    return {
      'number': ticketNumber,
      'vehicle': vehicle.toMap(),
      'traveller_count': numberOfTravelers,
      'entry': entryCheckPoint,
      'stay': stayStatus,
      'date': entryTime,
      'entry_ts': entryTime,
      "created_ts": entryTime,
      'exit': exitCheckPoint,
      'exit_ts': exitTime,
      'total_fine': totalfine,
      'gatekeeper': keeperID,
      'has_exited': hasExited,
      'fine': fine != null && fine.isNotEmpty
          ? fine?.map((x) => x?.toMap())?.toList()
          : [],
      // 'fine':fines.toMap()
    };
  }

  factory EntryTicketModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return EntryTicketModel(
        ticketNumber: map['number'].toString(),
        vehicle: Vehicle.fromMap(map['vehicle']),
        numberOfTravelers: map['traveller_count'].toString(),
        date: map["created_ts"],
        entryCheckPoint: map['entry'],
        exitCheckPoint: map['exit'],
        entryTime: map['entry_ts'],
        hasExited: map['has_exited'],
        keeperID: map['gatekeeper'].toString(),
        exitTime: map["exit_ts"],
        stayStatus: map['stay'],
        totalfine: map['total_fine'].toString(),
        fine: (map['fine'] as List).map((e) => Fine.fromMap(e)).toList());
  }
  String toJson() => json.encode(toMap());

  factory EntryTicketModel.fromJson(String source) =>
      EntryTicketModel.fromMap(json.decode(source));

  // String toJson() => json.encode(toMap());

  // factory EntryTicketModel.fromJson(String source) =>
  //     EntryTicketModel.fromMap(json.decode(source));
}
