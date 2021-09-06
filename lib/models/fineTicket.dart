import 'dart:convert';

import 'package:BRT/models/vehicle.dart';

class FineTicketModel {
  String ticketNumber;
  Vehicle vehicle;
  String numberOfTravelers;
  String stayStatus;
  FineTicketModel({
    this.ticketNumber,
    this.vehicle,
    this.numberOfTravelers,
    this.stayStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'number': ticketNumber,
      'vehicle': vehicle?.toMap(),
      'traveller_count': numberOfTravelers,
      'stayStatus': stayStatus,
    };
  }

  // factory EntryTicketModel.fromMap(Map<String, dynamic> map) {
  //   if (map == null) return null;

  //   return EntryTicketModel(
  //     ticketNumber: map['number'],
  //   vehicle: VehicleNumber.fromMap(map['vehicleNumber']),
  //     driverName: map['driver_name'],
  //     driverMobileNumber: map['driver_phone'],
  //     numberOfTravelers: map['traveller_count'],
  //     stayStatus: map['stayStatus'],
  //     location: map['state'],
  //   );
  // }

  factory FineTicketModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return FineTicketModel(
      ticketNumber: map['number'],
      vehicle: Vehicle.fromMap(map['vehicle']),
      numberOfTravelers: map['traveller_count'],
      stayStatus: map['stayStatus'],
    );
  }

  String toJson() => json.encode(toMap());

  factory FineTicketModel.fromJson(String source) =>
      FineTicketModel.fromMap(json.decode(source));
}
