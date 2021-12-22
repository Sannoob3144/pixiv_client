import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import 'package:pixiv_client/data/pixiv_api_constants.dart';

// Ref: https://gist.github.com/ZipFile/c9ebedb224406f4f11845ab700124362

class OAuthPKCE {
  late String codeChallenge;
  late String codeVerifier;

  OAuthPKCE({required String codeVerifier, required String codeChallenge}) {
    this.codeVerifier = codeVerifier;
    this.codeChallenge = codeChallenge;
  }
}

class AuthToken {
  late String accessToken;
  late String refreshToken;

  AuthToken({required String accessToken, required String refreshToken}) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}


class PixivOAuth2Client {
  String _clientId = "MOBrBDS8blbauoSck0ZfDbtuzpyT";
  String _clientSecret = "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj";

  late OAuthPKCE oAuthCode;
  late Map<String, String> oAuthQueryParams;

  PixivOAuth2Client() { // SHA256 transform
    AsciiCodec asciiConvert = new AsciiCodec();
    final codeVerifier = _generateRandomString(32); // Generate Random String
    final hashedChallenge = sha256.convert(asciiConvert.encode(codeVerifier)); // bytes -> sha256 convert (digest)
    final codeChallenge = _removeEnd(base64UrlEncode(hashedChallenge.bytes), "="); // digest bytes -> base64Url -> remove "=="

    oAuthCode =  OAuthPKCE(codeVerifier: codeVerifier, codeChallenge: codeChallenge);
    oAuthQueryParams = {
      'code_challenge': oAuthCode.codeChallenge,
      'code_challenge_method': 'S256',
      'client': 'pixiv-android',
    };
  }

  Uri get loginUri {
    return Uri.https(PIXIV_APP_API, PIXIV_LOGIN_PATH,
        this.oAuthQueryParams);
  }

  Future<Map> login (String code) async {
    Map<String, String> headers = {"User-Agent": USER_AGENT};
    Map<String, String> body = {
      "client_id": _clientId,
      "client_secret": _clientSecret,
      "code": code,
      "code_verifier": oAuthCode.codeVerifier,
      "grant_type": "authorization_code",
      "include_policy": "true",
      "redirect_uri": Uri.https(PIXIV_APP_API, PIXIV_CALLBACK_PATH).toString(),
    };

    Uri authTokenURL = Uri.https(PIXIV_OAUTH_SECURE_API, PIXIV_AUTH_TOKEN_URL);
    final http.Response response = await http.post(authTokenURL, headers: headers, body: body);
    final Map decodedJson = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (response.statusCode != 200) throw new Exception("Error on request, try again (Status code: ${response.statusCode})\n${response.body}");
    print(decodedJson);
    return decodedJson;
  }

  String _removeEnd(String str, String char) {
    var res = str;
    while (res.endsWith(char)) {
      res = res.substring(0, res.length - 1);
    }
    return res;
  }

  String _generateRandomString(int len) {
    var r = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }
}