import 'dart:async';
import 'dart:convert';

import 'package:BRT/main.dart';
import 'package:BRT/services/httpServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationViewModel extends ChangeNotifier {
  Timer authTimer;
  String _token;
  String _userName;
  String _userID;
  DateTime expireTime;
  String _checkPostName;
  // String _userName;

  bool get isAuthenticated {
    return (token != null && userID != null);
  }

  String get userName => _userName;
  String get checkPostName => _checkPostName;
  set userName(String user) {
    _userName = user;
    notifyListeners();
  }

  set checkPostName(String checkPost) {
    _checkPostName = checkPost;
    notifyListeners();
  }

  String get userID {
    return _userID;
  }

  String get token {
    if (_token != null &&
        expireTime != null &&
        expireTime.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String _getJsonFromJWT(String encodedStr) {
    String normalizedSource = base64Url.normalize(encodedStr);
    return utf8.decode(base64Url.decode(normalizedSource));
  }

  Future<void> storeUserDetails(Response response) async {
    if (response.object != null) {
      final body = await json.decode(response.object);
      _token = body["token"];
      _checkPostName = body['checkpost_name'];
      //   userName = body['user_name'];
      final decodedToken = _getJsonFromJWT(_token.split('.')[1]);
      final decodedJSON = json.decode(decodedToken);
      expireTime = DateTime.fromMicrosecondsSinceEpoch(
          (decodedJSON["exp"]).toInt() * 1000000);
      _userID = decodedJSON["user_id"].toString();
      // autoLogOut();
      notifyListeners();
      final preferences = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'expire': expireTime.toIso8601String(),
        'id': _userID,
        'checkpost_name': _checkPostName
        //     'user_name': _userName
      });
      await preferences.setString('userData', userData);
    }
  }

  Future<Response> signInUser({String userName, String password}) async {
    final response = await postRequest(
      signUp: true,
      body: {"email": userName, "password": password},
      api: 'account/login',
      successStatusCode: 200,
    );
    if (response.didSucceed) {
      await storeUserDetails(response);
      accessToken = _token;
      userId = _userID;
      checkPost = _checkPostName;
    }

    notifyListeners();
    return response;
  }

  Future<bool> tryAutoLogIn() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(preferences.getString('userData')) as Map<String, Object>;
    final expiryTime = DateTime.parse(extractedUserData['expire']);
    if (expiryTime.isBefore(DateTime.now())) {
      logout();
      return false;
    }
    _token = extractedUserData['token'];
    print(_token);
    _userID = extractedUserData['id'].toString();
    accessToken = _token;
    _checkPostName = extractedUserData['checkpost_name'];
    _userName = extractedUserData['user_name'];
    expireTime = expiryTime;
    checkPost = _checkPostName;
    userId = _userID;
    //autoLogOut();
    return true;
  }

  void logout() async {
    if (authTimer != null) {
      authTimer.cancel();
      authTimer = null;
    }
    _token = null;
    expireTime = null;
    userId = null;
    final preferences = await SharedPreferences.getInstance();
    preferences.clear();
    notifyListeners();
  }
}
