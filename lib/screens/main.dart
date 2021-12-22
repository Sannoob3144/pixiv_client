import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class MainScreen extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

class MainState extends State<MainScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<bool> _loginDataExists() async {
    final Database database = await openDatabase(
      path.join(await getDatabasesPath(), 'data.db'),
      version: 1,
      onCreate: (db, version) {
        print("Database on create.");
        db.execute(
            'create table loginData (accessToken text, refreshToken text);');
      },
    );
    final List<Map<String, dynamic>> queryRes =
        await database.query("loginData");
    // return queryRes.length > 0 ? true : false;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Main Screen")),
        body: FutureBuilder(
            future: _loginDataExists(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapShot) {
              if (!snapShot.hasData) {
                return CircularProgressIndicator();
              } else if (snapShot.data == false) {
                return Center(
                    child: ElevatedButton(
                        child: Text("Login with pixiv"),
                        onPressed: () {
                          Navigator.pushNamed(context, "/login");
                        }));
              } else {
                return Text("Login data already in database");
              }
            }));
  }
}
