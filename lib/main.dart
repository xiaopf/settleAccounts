import 'package:flutter/material.dart';
import './Home.dart';

import 'package:flutter/rendering.dart';
void main(){
  // debugPaintSizeEnabled=false;
  runApp(SettleAccounts());
}

class SettleAccounts extends StatefulWidget {
    @override
  _SettleAccountsState createState() => new _SettleAccountsState();
}
class _SettleAccountsState extends State<SettleAccounts> {
  bool splash = true;
  @override
  void initState() {
    new Future.delayed(Duration(seconds: 2), () {
      setState((){
        splash = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: splash ? SplashPage() : Home(),
    );
  }
}

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Image.asset("images/splash.png", fit: BoxFit.contain),
    );
  }
}