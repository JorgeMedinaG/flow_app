import 'package:econatu/src/user_preferences.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:progress_dialog/progress_dialog.dart';

import 'package:econatu/src/network_services.dart';
import 'package:econatu/src/db_provider.dart';

import '../src/db_provider.dart';


final _darkgreen = Color.fromRGBO(51, 102, 0, 1);

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {


    static var chartdisplay; 
    final _network = Network();
    final _prefs = new UserPreferences();
    ProgressDialog pr;
    
    List<addcharts> data = [];
    String _graphtitle = "";
    double _chartlong = 0.3;
    
    
    void initState() {
      setState(() {

        var data = [
          addcharts(" ", 0),
          addcharts(" ", 0),
          addcharts(" ", 0),
          addcharts(" ", 0),
          addcharts(" ", 0),
          addcharts(" ", 0),
        ];
        
        _buildGraph(data);


      });
    }
  
  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr.style(message: "Please wait..."); 
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton( icon: Icon(Icons.settings),
                      onPressed: () => Navigator.pushNamed(context, 'settings')
                      ,)
        ],
        backgroundColor: _darkgreen,
        centerTitle: true,
        title: Text("Historico de Fluxo"),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[ Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
              Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.90 ,
              child: Image.asset('assets/EcoNatu_Logo_Final_3.jpg'),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                          Container(
                              height: MediaQuery.of(context).size.height * 0.03,
                              child: Text(_graphtitle, style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025, color: _darkgreen), ),
                            ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.03,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Last updated: ", style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018, color: _darkgreen), ),
                                Text(_prefs.lastUpdate ?? "", style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018, color: _darkgreen)),
                              ],
                            )
                          ),
                    ],
                  ),
                  IconButton(icon: Icon(Icons.refresh), iconSize: 16.0,color: _darkgreen , onPressed: _updateData,), 

                ],
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * _chartlong,
                  maxWidth: MediaQuery.of(context).size.width * 0.90
                ),
                child: chartdisplay,
              ),
              // Container(
              //     height: MediaQuery.of(context).size.height * _chartlong,
              //     width: MediaQuery.of(context).size.width * 0.90,
              //     child:  chartdisplay,
                  
              //     ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
              _buttons(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
            ],
          ),
          ]
        ),
      ),
    );
  }

  Widget _buttons() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          RaisedButton(
            child: Text("Month"),
            textColor: _darkgreen,
            onPressed: () => _createMonthlyChart(),
          ), 
          RaisedButton(
            child: Text("Daily"),
            textColor: _darkgreen,
            onPressed: () => _createDailyChart(),
          ), 
           RaisedButton(
            child: Text("Hours"),
            textColor: _darkgreen,
            onPressed: () => _createHourlyChart(),
          ),
        ],
    );


  }
  
  _updateData() async {
    
    if (_prefs.routerip == null || _prefs.routerip == ""){
      _resultAlert("No ESP registered");
    } else {
      pr.show();
      print("Looking for data on ${_prefs.routerip}");
      final result = await _network.fetchData(); 
      
      if (result['ok'] == false ){
        print(result['error']);
        pr.hide().then((isHidden) {
          print(isHidden);
        });
        _resultAlert(result['error']);
      }

      pr.hide().then((isHidden) {
        print(isHidden);
      });      
      setState(() {
        
      });

    }
 
  }


  _createMonthlyChart() async {

    var res; 
    // DBProvider.db.createTestData();
    final result = await DBProvider.db.getMonthlyData();
    if (result["ok"]){
      res = result["res"];
    } else {
      _resultAlert(result["error"]);
      return;
    }
    print(res);
    if (res.length == 0 || res.length == null) {
      _resultAlert("No data found on ESP");
      print("No data");
    } else {

    
    List<addcharts> data1 = [];
    for (var i = 0; i < res.length; i++) {
      final row = res[i];
      data1.add( addcharts(row['label'], row['total']));
    }

    setState(() {
      data = data1;
      _buildGraph(data);
      _graphtitle = "Last 6 Months";
      _chartlong = 0.5;
    });
    }


  }

  _createDailyChart() async {

    var res;

    final result = await DBProvider.db.getDailyData();
    if (result["ok"]){
      res = result["res"];
    } else {
      _resultAlert(result["error"]);
      return;
    }
    
    if (res.length == 0 || res.length == null) {
        _resultAlert("No data found on ESP");
        print("No data");
    } else {
    
    List<addcharts> data1 = [];
    for (var i = 0; i < res.length; i++) {
      final row = res[i];
      data1.add( addcharts(row['label'], row['total']));
    }

    setState(() {
      data = data1;
      _buildGraph(data);
      _graphtitle = "Last 30 Days";
      _chartlong = res.length * 0.05;
      //_chartlong = 0.6;
    });
    }



  }

  _createHourlyChart() async{

    final result = await DBProvider.db.getHourlyData();

    var res;

    if (result["ok"]){
      res = result["res"];
    } else {
      _resultAlert(result["error"]);
      return;
    }
    
    if (res.length == 0 || res.length == null) {
      _resultAlert("No data found on ESP");
      print("No Data");
    } else {
    
    List<addcharts> data1 = [];
    for (var i = 0; i < res.length; i++) {
      final row = res[i];
      data1.add( addcharts(row['label'], row['total']));
    }

    setState(() {
      data = data1;
      _buildGraph(data);
      _graphtitle = "Last 72 Hours";
      _chartlong = res.length * 0.05;
      //_chartlong = 0.75;
    });

    }


  }

  _buildGraph(List<addcharts> data) {

      var series = [charts.Series(
        domainFn: (addcharts addcharts, _) =>addcharts.label,
        measureFn:  (addcharts addcharts, _) =>addcharts.value,
        id: 'addcharts', 
        data: data,
        seriesColor: charts.Color(g: 102, b:51 , r: 0, ),
        displayName: "Historico de Fluxo" , 
        labelAccessorFn :(addcharts addcharts, _) => "${addcharts.value}",
        ),];

      chartdisplay = charts.BarChart(
        series, 
        animate: true,
        animationDuration: Duration(milliseconds: 500),
        vertical: false,
        barRendererDecorator: charts.BarLabelDecorator<String>(
          labelPosition: charts.BarLabelPosition.auto,
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(

          renderSpec: charts.GridlineRendererSpec(
            axisLineStyle: charts.LineStyleSpec(
              thickness: 10,
            )
          )
        ),
        
      );

  }

    _resultAlert(String result) {
        showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return CupertinoAlertDialog(  

            title: Column(
              children: <Widget>[
                Text("$result",style: TextStyle(fontSize: 18.0, color: Colors.black), textAlign: TextAlign.center, ),
              ],
            ),

            actions: <Widget>[
              FlatButton(
                  //  elevation: 0.0,
                    textColor: Colors.blue,
                    child: Text("Ok", style: TextStyle(fontSize: 14),),
                    onPressed: () => Navigator.pop(context),
                  ),
                           
            ],
          );
        }
    );  
  }


  

}



class addcharts {

    final String label; 
    final int value; 
    addcharts(this.label, this.value);
}
