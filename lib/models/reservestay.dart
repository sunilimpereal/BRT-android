import 'dart:convert';

import 'package:BRT/models/reserve.dart';

import 'package:BRT/models/states.dart';

class ReserveStay {
  Reserve reserve;
  String id;

  String locationName;
  bool status;
  ReserveStay({this.id, this.reserve, this.locationName, this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reserve': reserve?.toMap(),
      'location': locationName,
      'status': status,
    };
  }

  factory ReserveStay.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ReserveStay(
        id: map['id'].toString(),
        reserve: Reserve.fromMap(map['reserve']),
        locationName: map['location'],
        status: map['status']);
  }

  String toJson() => json.encode(toMap());

  factory ReserveStay.fromJson(String source) =>
      ReserveStay.fromMap(json.decode(source));
}
