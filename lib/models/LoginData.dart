class LoginData {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpires;

  LoginData({required this.accessToken, required this.refreshToken, required this.accessTokenExpires});
}