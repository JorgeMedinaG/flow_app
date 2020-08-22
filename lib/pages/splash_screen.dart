import 'dart:async';
import 'package:flutter/material.dart';
import 'package:econatu/src/user_preferences.dart';


class SplashScreen extends StatefulWidget {


  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final _prefs = new UserPreferences();
  //final _network = new Network();
  
  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() async {

    if (_prefs.username == null || _prefs.username == ""){
      
      Navigator.of(context).pushReplacementNamed('login');
    } else {
      print("Usuario: ${_prefs.username}");
      // final result = await _network.findDNS();
      // if (result){
      //     await _network.fetchData();
      // }
      Navigator.of(context).pushReplacementNamed('graph');
    }

  
  }

  @override
  void initState() {
  super.initState();
  startTime();
}
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white ,
      body: Center (
        child: Container(
          width: MediaQuery.of(context).size.width * 0.90 ,
          child: Image.asset('assets/EcoNatu_Logo_Final.jpg'),
        ),
      ),
    ); 
  }



}