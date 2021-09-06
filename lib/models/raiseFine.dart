import 'dart:convert';

import 'package:BRT/models/fine.dart';

class RaisedFineModel {
  List<Fine> fine;
  String ticketNumber;

  RaisedFineModel({this.fine, this.ticketNumber});
  Map<String, dynamic> toMap() {
    return {
      'fine': fine?.map((x) => x?.toMap())?.toList(),
      'ticket': ticketNumber,
    };
  }

  factory RaisedFineModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return RaisedFineModel(
      fine: List<Fine>.from(map['fine']?.map((x) => Fine.fromMap(x))),
      ticketNumber: map['ticket'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RaisedFineModel.fromJson(String source) =>
      RaisedFineModel.fromMap(json.decode(source));
}
