// To parse this JSON data, do
//
//     final startTripRequestModel = startTripRequestModelFromJson(jsonString);

import 'dart:convert';

StartTripRequestModel startTripRequestModelFromJson(String str) => StartTripRequestModel.fromJson(json.decode(str));

String startTripRequestModelToJson(StartTripRequestModel data) => json.encode(data.toJson());

class StartTripRequestModel {
    StartTripRequestModel({
        this.sfrDevice,
        this.sfrVehicle,
        this.sfrDriver,
        this.sfrNaturelist,
    });

    String sfrDevice;
    String sfrVehicle;
    String sfrDriver;
    String sfrNaturelist;

    factory StartTripRequestModel.fromJson(Map<String, dynamic> json) => StartTripRequestModel(
        sfrDevice: json["sfr_device"],
        sfrVehicle: json["sfr_vehicle"],
        sfrDriver: json["sfr_driver"],
        sfrNaturelist: json["sfr_naturelist"],
    );

    Map<String, dynamic> toJson() => {
        "sfr_device": sfrDevice,
        "sfr_vehicle": sfrVehicle,
        "sfr_driver": sfrDriver,
        "sfr_naturelist": sfrNaturelist,
    };
}

// To parse this JSON data, do
//
//     final startTripResponseModel = startTripResponseModelFromJson(jsonString);



StartTripResponseModel startTripResponseModelFromJson(String str) => StartTripResponseModel.fromJson(json.decode(str));

String startTripResponseModelToJson(StartTripResponseModel data) => json.encode(data.toJson());

class StartTripResponseModel {
    StartTripResponseModel({
        this.tripid,
        this.ermsg,
        this.tripstatus,
    });

    String tripid;
    bool ermsg;
    String tripstatus;

    factory StartTripResponseModel.fromJson(Map<String, dynamic> json) => StartTripResponseModel(
        tripid: json["tripid"],
        ermsg: json["ermsg"],
        tripstatus: json["tripstatus"],
    );

    Map<String, dynamic> toJson() => {
        "tripid": tripid,
        "ermsg": ermsg,
        "tripstatus": tripstatus,
    };
}
