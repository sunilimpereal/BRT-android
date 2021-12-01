// To parse this JSON data, do
//
//     final endTripRequestModel = endTripRequestModelFromJson(jsonString);

import 'dart:convert';

EndTripRequestModel endTripRequestModelFromJson(String str) => EndTripRequestModel.fromJson(json.decode(str));

String endTripRequestModelToJson(EndTripRequestModel data) => json.encode(data.toJson());

class EndTripRequestModel {
    EndTripRequestModel({
        this.tripid,
    });

    String tripid;

    factory EndTripRequestModel.fromJson(Map<String, dynamic> json) => EndTripRequestModel(
        tripid: json["tripid"],
    );

    Map<String, dynamic> toJson() => {
        "tripid": tripid,
    };
}
