import 'package:flutter/material.dart';

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
          body: Center(
            child: Text("Hello World"),
          )),
    );
  }
}
