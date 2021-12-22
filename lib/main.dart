import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:pixiv_client/screens/login.dart';
import 'package:pixiv_client/screens/main.dart';

var initialRoute = "/";

void main() {
  runZonedGuarded(() {
    runApp(PixivClient());
  }, (error, stack) {
    print('- App is crashed');
    print('- Error message');
    print(error);
    print('- Stack trace');
    print(stack);
    Fluttertoast.showToast(msg: "${error.toString()} ${stack.toString()}");
  });
}

class PixivClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: initialRoute, routes: {
      "/": (context) => MainScreen(),
      "/login": (context) => LoginScreen(),
    });
  }
}
