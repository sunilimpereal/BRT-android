import 'dart:convert';

import 'package:BRT/models/checkpost.dart';
import 'package:BRT/services/httpServices.dart';

class CheckPostViewModel {
  final String _accessToken;

  CheckPostViewModel(this._accessToken);
  Future<List<CheckPost>> getCheckPostList() async {
    final List<CheckPost> checkPosts = [];
    final response = await getRequest(
        accessToken: _accessToken,
        api: "reserve-checkpost/",
        successStatusCode: 200);
    if (response.didSucceed) {
      if (response.object != null) {
        final decodedResponse = json.decode(response.object);
        for (var state in decodedResponse) {
          CheckPost statesModel = CheckPost.fromMap(state);
          checkPosts.add(statesModel);
        }
      }
    }
    return checkPosts;
  }
}
