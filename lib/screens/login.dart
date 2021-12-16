import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/pixiv_api_constants.dart';
import '../utils/oauth2_flow.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginState createState() => new LoginState();
}

class LoginState extends State<LoginScreen> {
  PixivOAuth2Client _pixivOAuth2Client = new PixivOAuth2Client();
  late AppLinks _appLinks;

  Future<void> authorize(bool chk) async {
    Fluttertoast.showToast(
        msg: "After login, Select Pixiv_Client",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0);
    await launch(Uri.https(PIXIV_APP_API, PIXIV_LOGIN_PATH,
            _pixivOAuth2Client.oAuthQueryParams)
        .toString());
  }

  @override
  void initState() { // Android intent filter -> 픽시브 리다이렉트 코드 부분 가져와서 OAuth 정보 가져오는 부분
    // TODO: implement initState
    super.initState();
    _appLinks = AppLinks(onAppLink: (Uri uri, String stringUri) {
      final pixivRedirect = Uri.https(PIXIV_APP_API, PIXIV_CALLBACK_PATH).toString();
      if (stringUri.startsWith(pixivRedirect) == true) {
        if (uri.queryParameters["code"] == null) return;
        else _pixivOAuth2Client.login(uri.queryParameters["code"] as String).then((res) => {
          print(res)
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          child: Text("Login with pixiv"), onPressed: () => {authorize(true)}),
    );
  }
}
