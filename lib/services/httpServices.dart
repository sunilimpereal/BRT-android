import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:BRT/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../strings.dart';

class Response {
  bool didSucceed;
  dynamic object;
  String responseMessage;

  Response(
      {@required this.didSucceed,
      @required this.object,
      @required this.responseMessage});
}

Future<Response> getRequest(
    {String accessToken,
    String api,
    int successStatusCode,
    bool userSignedIn = true}) async {
  var didSucceed = false;
  var message = genericErrorMessage;
  final url = BackendBaseUrl + api;
  dynamic decodedResponseBody;
  final headers = {contentTypeKey: applicationJSONTypeKey};
  if (userSignedIn) {
    headers[authorizationKey] = '$bearerKey $accessToken';
  }
  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == successStatusCode) {
      didSucceed = true;
      decodedResponseBody = response.body;
      log("api url : ${url}");
      log("api url : ${response.body}");
      message = 'Successful';
    } else {
      final body = json.decode(response.body.toString());
      message = body['message'];
    }
  } on SocketException catch (_) {
    message = internetUnavailableMessage;
  } catch (error) {
    message = error.toString();
  }
  return Response(
      didSucceed: didSucceed,
      responseMessage: message,
      object: decodedResponseBody);
}

Future<Response> patchRequest({
  dynamic body,
  String accessToken,
  String api,
  int successStatusCode,
}) async {
  var didSucceed = false;
  var message = genericErrorMessage;
  final url = BackendBaseUrl + api;
  dynamic decodedResponseBody;
  final headers = {
    contentTypeKey: applicationJSONTypeKey,
    authorizationKey: '$bearerKey $accessToken'
  };
  try {
    final response =
        await http.patch(url, body: json.encode(body), headers: headers);
    if (response.statusCode == successStatusCode) {
      didSucceed = true;
      decodedResponseBody = response.body;
      message = 'Successful';
    } else {
      final body = json.decode(response.body);
      message = body['message'];
    }
  } on SocketException catch (_) {
    message = internetUnavailableMessage;
  } catch (error) {
    message = error.toString();
  }
  return Response(
      didSucceed: didSucceed,
      responseMessage: message,
      object: decodedResponseBody);
}

Future<Response> putRequest(
    {String accessToken,
    String api,
    dynamic body,
    int successStatusCode,
    bool userSignedIn = true}) async {
  var didSucceed = false;
  var message = genericErrorMessage;
  final url = BackendBaseUrl + api;
  dynamic decodedResponseBody;
  final headers = {contentTypeKey: applicationJSONTypeKey};
  if (userSignedIn) {
    headers[authorizationKey] = '$bearerKey $accessToken';
  }
  try {
    final response =
        await http.put(url, body: json.encode(body), headers: headers);
    decodedResponseBody = response.body;
    if (response.statusCode == successStatusCode ||
        response.statusCode == 201) {
      didSucceed = true;
      message = 'Successful';
    } else {
      final body = json.decode(response.body.toString());
      if (body.values.first is List) {
        message = body.values.first.first;
      } else {
        message = body.values.first;
      }
    }
  } on SocketException catch (_) {
    message = internetUnavailableMessage;
  } catch (error) {
    message = genericErrorMessage;
  }
  final patientResponse = Response(
      didSucceed: didSucceed,
      responseMessage: message,
      object: decodedResponseBody);
  return patientResponse;
}

Future<Response> postRequest(
    {String accessToken,
    String api,
    dynamic body,
    bool signUp = false,
    int successStatusCode}) async {
  var didSucceed = false;
  var message = genericErrorMessage;
  final url = BackendBaseUrl + api;
  dynamic decodedResponseBody;
  final headers = {contentTypeKey: applicationJSONTypeKey};
  if (!signUp) {
    headers[authorizationKey] = '$bearerKey $accessToken';
  }
  try {
    final response =
        await http.post(url, body: json.encode(body), headers: headers);
    decodedResponseBody = response.body;
    if (response.statusCode == successStatusCode) {
      didSucceed = true;
      message = 'Successful';
    } else {
      final body = json.decode(response.body.toString());
      if (body.values.first is List) {
        message = body.values.first.first;
      } else {
        message = body.values.first;
      }
    }
  } on SocketException catch (_) {
    message = internetUnavailableMessage;
  } catch (error) {
    message = genericErrorMessage;
  }
  final patientResponse = Response(
      didSucceed: didSucceed,
      responseMessage: message,
      object: decodedResponseBody);
  return patientResponse;
}
