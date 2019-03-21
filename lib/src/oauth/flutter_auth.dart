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

import 'dart:async';
import 'dart:io';

import 'package:auth/src/oauth/auth_code_information.dart';
import 'package:auth/src/oauth/model/config.dart';
import 'package:auth/src/oauth/oauth.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class FlutterOAuth extends OAuth {
  final StreamController<String> onCodeListener = StreamController();

  final FlutterWebviewPlugin webView = FlutterWebviewPlugin();

  var isBrowserOpen = false;
  var server;
  var onCodeStream;

  Stream<String> get onCode =>
      onCodeStream ??= onCodeListener.stream.asBroadcastStream();

  FlutterOAuth(Config configuration) :
        super(configuration, AuthorizationRequest(configuration));

  Future<String> requestCode() async {
    if (shouldRequestCode() && !isBrowserOpen) {
//      await webView.close();
      isBrowserOpen = true;

      server = await createServer();
      listenForServerResponse(server);

      final String urlParams = constructUrlParams();
      webView.onDestroy.first.then((_) {
        close();
      });

      webView.launch("${requestDetails.url}?$urlParams",
          clearCookies: requestDetails.clearCookies,
          withZoom: requestDetails.fullScreen);

      code = await onCode.first;
      close();
    }
    return code;
  }

  void close() {
    if (isBrowserOpen) {
      server.close(force: true);
      webView.close();
    }
    isBrowserOpen = false;
  }

  Future<HttpServer> createServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080,
        shared: true);
    return server;
  }

  listenForServerResponse(HttpServer server) {
    server.listen((HttpRequest request) async {
      final uri = request.uri;
      request.response
        ..statusCode = 200
        ..headers.set("Content-Type", ContentType.html.mimeType);

      final code = uri.queryParameters["code"];
      final error = uri.queryParameters["error"];
      await request.response.close();
      if (code != null && error == null) {
        onCodeListener.add(code);
      } else if (error != null) {
        onCodeListener.add(null);
        onCodeListener.addError(error);
      }
    });
  }

}