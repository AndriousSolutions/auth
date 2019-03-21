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

import 'package:auth/src/oauth/model/config.dart';

class TokenRequestDetails {

  String url;
  Map<String, String> params;
  Map<String, String> headers;

  TokenRequestDetails(Config configuration, String code) {
    this.url = configuration.tokenUrl;
    this.params = {
      "client_id": configuration.clientId,
      "client_secret": configuration.clientSecret,
      "code": code,
      "redirect_uri": configuration.redirectUri
//      ,"grant_type": "authorization_code"
    };
    this.headers = {
      "Accept": "application/json",
      "Content-Type": configuration.contentType
    };
    if (configuration.headers != null) {
      this.headers.addAll(headers);
    }
  }

}