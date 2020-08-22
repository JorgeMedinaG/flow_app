import 'dart:async';
import 'dart:io';

import 'package:mdns_plugin/mdns_plugin.dart';
//import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'dart:io' show Platform;

import 'package:econatu/src/user_preferences.dart';
import 'package:econatu/src/db_provider.dart';
//import 'package:econatu/src/mdns_plugin.dart';



final _prefs = new UserPreferences();
bool found = false;
List<dynamic> devices = [];

class Network {

    

    
    
    Future<Map<String,dynamic>> fetchData() async {

      var resp;
      final String ip = _prefs.routerip;
      print("Direction:");
      print("http://"+ip+"/dataTable");
      try {
        resp = await http.get("http://"+ip+"/dataTable");
      } catch (error) {
        if (error is SocketException){
          print(error);
          return {"ok" : false, "error": error.osError.message};
        } else {
          return {"ok" : false, "error": error};
        }
        
        
      } 
      

      if (resp.statusCode == 200){ 

          final decodedHeader =( resp.body );  
          List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(decodedHeader);
          
          if (rowsAsListOfValues.length > 0) {
              await DBProvider.db.registerFile(rowsAsListOfValues);
              _prefs.lastUpdate = new DateTime.now().toString().substring(0,19);
              return {"ok" : true};
          } else {
            return {"ok" : false, "error": "No data on ESP"};
          } 

      } else {
            return {"ok" : false, "error": "${resp.statusCode} - "+resp.reasonPhrase};
      }
      
    
    }
    


  // Future<bool> findDNS() async {
  //       found = false;
  //       MDNSPlugin _mdns = new MDNSPlugin(_Delegate());
  //       await _mdns.startDiscovery("_http._tcp",enableUpdating: false);
  //       await _sleep();
  //       await _mdns.stopDiscovery();
  //       return found;
  //   }

  Future<Map<String,dynamic>> findDNS() async {
        found = false;
        devices = [];
        MDNSPlugin _mdns = new MDNSPlugin(_Delegate());
        await _mdns.startDiscovery("_http._tcp",enableUpdating: false);
        await _sleep();
        await _mdns.stopDiscovery();
        return {"ok" : found, "list": devices};
    }    

    Future _sleep() {
      return new Future.delayed(const Duration(seconds: 4), () => "4");
    }

}



class _Delegate implements MDNSPluginDelegate {

  
  void onDiscoveryStarted() {
      print("Discovery started");
  }
  void onDiscoveryStopped() {
      print("Discovery stopped");
  }
  bool onServiceFound(MDNSService service) {
      print("Found: $service");
      // Always returns true which begins service resolution
      return true;
  }
  void onServiceResolved(MDNSService service) {
      print("Resolved: $service");
      if (service.name == "esp32") {
        
        if (Platform.isIOS) {
          devices = service.addresses;
        } else if (Platform.isAndroid) {
          devices.add(service.hostName);
          print(devices);
        }
        //print(service.addresses);
        //devices = service.addresses;
        found = true;
      } 

      

  }
  void onServiceUpdated(MDNSService service) {
      print("Updated: $service");
  }
  void onServiceRemoved(MDNSService service) {
      print("Removed: $service");
  }
}
  





///In case needed 
///  _launchURL() async {
  // const url = 'http://10.0.0.111/';
  // if (await canLaunch(url)) {
  //   await launch(url, forceWebView: true);
  // } else {
  //   throw 'Could not launch $url';
  // }
  // }

