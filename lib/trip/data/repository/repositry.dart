import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../../config_.dart';

class API {

  static Future<Response> get(
      {@required BuildContext context,
      @required String url,
      String apiRoot,
      Map<String, String> headers1}) async {
    try {
      log('url: ${apiRoot ?? Config.TRIP_API_ROOT}${url} ');
      var response = await http.get(Uri.parse("${apiRoot ?? Config.TRIP_API_ROOT}$url"),
          headers: headers1 );
      log('respose: ${Uri.parse("${apiRoot ?? Config.TRIP_API_ROOT}$url").toString()}');
      log('respose: ${response.statusCode}');
      log('respose: ${response.body}');
      return response;
    } finally {
      //TODO : Dialog box
    }
  }

  static Future<Response> post({
    @required String url,
    @required Object body,
   @required BuildContext context,
    Map<String, String> headers,
    String apiRoot,
    bool logs,
  }) async {
    try {
      log('url: ${apiRoot ?? Config.TRIP_API_ROOT}${url} ');
      log('body: $body');
      var response = await http.post(Uri.parse("${apiRoot ?? Config.TRIP_API_ROOT}$url"),
          body: body, headers: headers );
      log('respose: ${response.statusCode}');
      log('respose: ${response.body}');

      return response;
    } finally {
      //TODO : Dialog box
    }
  }

  static Future<Response> patch({
    @required String url,
    @required Object body,
    @required BuildContext context,
    Map<String, String> headers,
    String apiRoot,
  }) async {
    try {
      log('url: ${apiRoot ?? Config.TRIP_API_ROOT}${url} ');
      log('body: $body');
      var response = await http.patch(Uri.parse("${apiRoot ?? Config.TRIP_API_ROOT}$url"),
          body: body, headers: headers );
      log('respose: ${response.statusCode}');
      log('respose: ${response.body}');

      return response;
    } finally {}
  }
}
