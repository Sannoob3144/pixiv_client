import 'package:flutter/material.dart';

import './screens/login.dart';
import './screens/main.dart';

void main() {
  runApp(PixivClient());
}

class PixivClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text('PixivClient'),
            ),
            body: MaterialApp(
              initialRoute: '/',
              routes: {
                '/': (context) => MainScreen(),
                '/login': (context) => LoginScreen()
              },
            )));
  }
}
