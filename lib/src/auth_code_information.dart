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

import 'package:auth/src/model/config.dart';

class AuthorizationRequest {

  String url;
  Map<String, String> parameters;
  Map<String, String> headers;
  bool fullScreen;
  bool clearCookies;

  AuthorizationRequest(Config config,
      {bool fullScreen: true, bool clearCookies: true}) {
    this.url = config.authorizationUrl;
    this.parameters = {
      "client_id": config.clientId,
//      "response_type": config.responseType,
      "redirect_uri": config.redirectUri,
    };
    if (config.parameters != null) {
      this.parameters.addAll(config.parameters);
    }
    this.fullScreen = fullScreen;
    this.clearCookies = clearCookies;
    this.headers = config.headers;
  }

}
