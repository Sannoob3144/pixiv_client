import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
// Hardcoding
import 'package:path/path.dart' as path;
import 'package:pixiv_client/data/pixiv_api_constants.dart';
import 'package:pixiv_client/models/LoginData.dart';
import 'package:pixiv_client/utils/oauth2_flow.dart';
import 'package:sqflite/sqflite.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginScreen> {
  PixivOAuth2Client _pixivOAuth2Client = PixivOAuth2Client();
  int _progress = 0; // Webview progress

  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? _controller;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        userAgent: USER_AGENT,
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  void _onLoadStart(
      BuildContext context, InAppWebViewController controller, Uri? uri) async {
    if (uri!.hasScheme && uri.scheme == "pixiv") {
      // pixiv://account/login 감지
      final code = uri.queryParameters["code"]; // 쿼리스트링의 code 확인 (nullable)
      if (code != null) {
        // null 이 아닌 값이라면 OAuth2 token 리퀘스트
        Fluttertoast.showToast(msg: code);
        final res = await _pixivOAuth2Client.login(code);
        final Database database = await openDatabase(
          path.join(await getDatabasesPath(), 'data.db'),
          version: 1,
          onCreate: (db, version) {
            print("Database on create.");
            db.execute(
                'create table loginData (accessToken text, refreshToken text);');
          },
        );
        final data = await database.insert(
            "loginData",
            LoginData(
                    accessToken: res["access_token"],
                    refreshToken: res["refresh_token"])
                .toMap());
        print(data);
        Fluttertoast.showToast(
            msg: "Login success, Welcome ${res["user"]["name"]}");
        Navigator.pop(context);
      } else {
        // code 가 null 이라면 인앱 웹뷰 페이지에서 나가고 에러 throw
        Navigator.pop(context);
        throw Exception("Error on login. \"code\" query parameter not found");
      }
    }
  }

  void _onProgressChanged(InAppWebViewController controller, int progress) {
    setState(() {
      _progress = progress; // AppBar 프로그레스 바
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( // Webview 엔터키로 나가지는거 방지
        onWillPop: () {
          Navigator.pop(context);
          return Future(() => false);
        },
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text("Pixiv Login"),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  )
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: IconButton(
                      onPressed: () {
                        _controller?.reload();
                      },
                      tooltip: "Refresh",
                      icon: const Icon(Icons.refresh),
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: IconButton(
                      onPressed: () {
                        _controller?.loadUrl(
                            urlRequest:
                                URLRequest(url: _pixivOAuth2Client.loginUri));
                      },
                      tooltip: "Home",
                      icon: const Icon(Icons.home),
                    ))
              ],
              bottom: PreferredSize(
                  preferredSize: Size(double.infinity, 0),
                  child: LinearProgressIndicator(
                    value: _progress / 100,
                    // value 가 double 만 받아서 _progress (퍼센트) 를 100 으로 나눠 0.0 ~ 1.0 값으로 처리함
                    backgroundColor: Colors.white,
                  )),
            ),
            body: InAppWebView(
              onWebViewCreated: (InAppWebViewController controller) =>
                  _controller = controller,
              key: webViewKey,
              onProgressChanged: _onProgressChanged,
              initialOptions: options,
              onLoadStart: (InAppWebViewController controller, Uri? uri) =>
                  _onLoadStart(context, controller, uri),
              // Navigator 사용을 위해 래핑 (좋은 코딩 방법은 아닌것 같음)
              initialUrlRequest: URLRequest(url: _pixivOAuth2Client.loginUri),
            )));
  }
}
