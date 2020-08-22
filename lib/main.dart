import 'package:econatu/pages/login_page.dart';
import 'package:econatu/pages/settings_page.dart';
import 'package:econatu/pages/splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:econatu/pages/graph_page.dart';
import 'package:econatu/src/user_preferences.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new UserPreferences();
  await prefs.initPrefs();

  runApp(MyApp());

}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow Logger',
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(),
      routes: {
        'graph'      : (BuildContext context) => GraphPage(), 
        'settings'    : (BuildContext context) => SettingsPage(),
        'login'       : (BuildContext context) => LoginPage()
      },
    );
  }
}
