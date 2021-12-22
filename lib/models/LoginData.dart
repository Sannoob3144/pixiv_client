class LoginData {
  final String accessToken;
  final String refreshToken;

  LoginData({required this.accessToken, required this.refreshToken});

  Map<String, dynamic> toMap() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    };
  }
}