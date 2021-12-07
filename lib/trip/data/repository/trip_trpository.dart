import 'dart:developer';

import 'package:BRT/trip/data/models/end_trip_request_model.dart';
import 'package:BRT/trip/data/models/start_trip_request_model.dart';
import 'package:BRT/trip/data/repository/repositry.dart';
import 'package:flutter/cupertino.dart';

class TripRepository {
  Future<StartTripResponseModel> startTrip(
      {StartTripRequestModel startTripRequestModel, BuildContext context}) async {
    final respose = await API.post(
      url: "startsafari",
      body: startTripRequestModelToJson(startTripRequestModel),
      context: context,
    );
    if (respose.statusCode == 200) {
      log("trip response : "+respose.body);
      return startTripResponseModelFromJson(respose.body);
    } else {
      return null;
    }
 
  }


    Future<EndTripRequestModel> endTrip(
      {EndTripRequestModel endTripRequestModel, BuildContext context}) async {
    final respose = await API.post(
      url: "endsafari/",
      body: endTripRequestModelToJson(endTripRequestModel),
      context: context,
    );
  
    if (respose.statusCode == 200) {
       log("code : "+respose.statusCode.toString());
      try{
      log("trip response : "+respose.body);
      return endTripRequestModelFromJson(respose.body);
      }catch(e){
        return EndTripRequestModel(
          tripid: endTripRequestModel.tripid
        );
      }
    } else {
      return null;
    }
  }
}
