///
/// Copyright (C) Joe Birch
///               https://github.com/hitherejoe/FlutterOAuth
///
/// This program is free software; you can redistribute it and/or
/// modify it under the terms of the GNU General Public License
/// as published by the Free Software Foundation; either version 3
/// of the License, or any later version.
///
/// You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  Aug 17, 2018
///
///

library flutter_oauth;

import 'dart:async';
import 'dart:convert';

import 'package:auth/src/oauth/auth_code_information.dart';
import 'package:auth/src/oauth/model/config.dart';
import 'package:auth/src/oauth/oauth_token.dart';
import 'package:auth/src/oauth/token.dart';
import 'package:http/http.dart';

abstract class OAuth {

  final Config configuration;
  final AuthorizationRequest requestDetails;
  String code;
  Map<String, dynamic> token;

  TokenRequestDetails tokenRequest;

  OAuth(this.configuration, this.requestDetails);

  Future<Map<String, dynamic>> getToken() async {
    if (token == null) {
      Response response = await post("${tokenRequest.url}",
          body: jsonEncode(tokenRequest.params),
          headers: tokenRequest.headers);
      token = jsonDecode(response.body);
    }
    return token;
  }

  bool shouldRequestCode() => code == null;

  String constructUrlParams() => mapToQueryParams(requestDetails.parameters);

  String mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add("$key=$value"));
    return queryParams.join("&");
  }

  void generateTokenRequest() {
    tokenRequest = TokenRequestDetails(configuration, code);
  }

  Future<Token> performAuthorization() async {
    String resultCode = await requestCode();
    if (resultCode != null) {
      generateTokenRequest();
      return Token.fromJson(await getToken());
    }
    return null;
  }

  Future<String> requestCode();

}