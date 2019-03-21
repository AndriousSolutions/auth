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

class Token {

  String accessToken;
  String tokenType;

  Token();

  factory Token.fromJson(Map<String, dynamic> json) =>
      Token.fromMap(json);

  Map toMap() => Token.toJsonMap(this);

  @override
  String toString() => Token.toJsonMap(this).toString();

  static Map toJsonMap(Token model) {
    Map ret = Map();
    if (model != null) {
      if (model.accessToken != null) {
        ret["access_token"] = model.accessToken;
      }
      if (model.tokenType != null) {
        ret["token_type"] = model.tokenType;
      }
    }
    return ret;
  }

  static Token fromMap(Map map) {
    if (map == null) return null;
    Token model = Token();
    model.accessToken = map["access_token"];
    model.tokenType = map["token_type"];
    return model;
  }

}