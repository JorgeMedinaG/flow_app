import 'package:flutter/material.dart';
import 'package:econatu/src/user_preferences.dart';
import 'package:econatu/src/user_provider.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:econatu/src/network_services.dart';
import 'package:progress_dialog/progress_dialog.dart';


final _darkgreen = Color.fromRGBO(51, 102, 0, 1);

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  
 //final _currentUser = GoogleUser.guser.currentUser;
 final usuario = UserPreferences();
 final facebookLogin = FacebookLogin();
 final _network = Network();
 ProgressDialog pr;

  @override
  Widget build(BuildContext context) {

    pr = new ProgressDialog(context);
    pr.style(message: "Please wait..."); 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _darkgreen,
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          _userDetail(),
          Divider(),
          _selectDevice(),
          Divider(),
          ListTile(
            title: Text("Billing Date"),
            leading: Icon(Icons.calendar_today),
            //subtitle: Text("Day: 12"),
          ),
          _dropdown(),
        ],
      ),
    );
  }

   _userDetail() {
    
    if (usuario.loginType == "google"){
      return _googleDetail();
    } else if (usuario.loginType == "fb"){
      return _fbDetail();
    }

  }
  Widget _googleDetail() {
    if (usuario.username != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ListTile(
            leading: 
            // GoogleUserCircleAvatar(
            //   placeholderPhotoUrl: usuario.photoURl,
            //   identity: _currentUser,
            // ),
             CircleAvatar(
              backgroundImage: NetworkImage(usuario.photoURl),
            ),
            title: Text(usuario.username?? ''),
            subtitle: Text(usuario.email ?? ''),
          ),
          RaisedButton(
            onPressed: _googleSignOut,
            child: Text('SIGN OUT'),
            textColor: _darkgreen,
          )
        ],
      );
    }
    else{
      return Center(child: Text("User not found"));
      
    }
  }
  
  Widget _fbDetail() {
    
    if (usuario.username != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(usuario.photoURl),
            ),
            title: Text(usuario.username ?? ''),
            subtitle: Text(usuario.email ?? ''),
          ),
          RaisedButton(
            onPressed: _fbSignOut,
            child: Text('SIGN OUT'),
            textColor: _darkgreen,
          )
        ],
      );
    }
    else{
      return Center(child: Text("User not found"));
      
    }
  }

  Widget _selectDevice() {
    
    String subtitle;
    print(usuario.routerip);
    if (usuario.routerip == null || usuario.routerip == ""){
      subtitle = "No device selected";
    } else {
      subtitle = "Configured on IP address: "+usuario.routerip;
    }

    return ListTile(
      leading: Icon(Icons.search),
      title: Text("Select ESP Device"),
      subtitle: Text(subtitle),
      onTap: () =>_searchDevices(context),
    );
  }

  _searchDevices(context) async {
    pr.show();

    final discover = await _network.findDNS();
    final List<Widget> opciones = [];
    if (discover['ok']){

        final data = discover['list'];
              data.forEach((opt) {
                final widgetTemp = ListTile(
                  title: Text("IP: $opt"),
                  onTap: (){
                    usuario.routerip = opt;
                    Navigator.of(context).pop();
                    setState(() {
                    });
                  },
                );
              opciones..add( widgetTemp )
                      ..add( Divider() );

              } );
    } else {
      final widgetTemp = ListTile(
        title: Text("No device found"),
      );
      opciones.add(widgetTemp);
      usuario.routerip = null;
      setState(() {});
    }

    pr.hide().then((isHidden) {
      print(isHidden);
    });

    _displayDialog(context, opciones);
    
  }

  _displayDialog(BuildContext context, List<Widget> opciones) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Devices availables on your network'),
            content: Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.3,
              child: ListView(
                //padding: EdgeInsets.all(8.0),
                children: opciones
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _googleSignOut() async{
    await GoogleUser.guser.signOut();
    _eraseData();
   // Navigator.of(context).pushReplacementNamed('login');
   Navigator.pushReplacementNamed(context, 'login');
  }

  void _fbSignOut() {
    facebookLogin.logOut();
    _eraseData();
   // Navigator.of(context).pushReplacementNamed('login');
    Navigator.pushReplacementNamed(context, 'login');
  }
  
  void _eraseData() {
    usuario.username = null;
    usuario.closedate = null; 
    usuario.photoURl = null; 
    usuario.email = null;
    usuario.routerip = null;
  }


  _dropdown(){
    String dropdownValue = usuario.closedate;
    
    return Row(
      children: <Widget>[
        SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
        Align(
              alignment: Alignment.centerLeft ,
              child: DropdownButton<String>(
                isDense: true,
                value: (dropdownValue),
                // icon: Icon(Icons.arrow_downward),
                // iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black),
                // underline: Container(
                //   height: 2,
                //   color: Colors.deepPurpleAccent,
                // ),
                onChanged: (String newValue) {
                  usuario.closedate = newValue;
                  setState(() {
                    dropdownValue = newValue;
                  });
                },
                items: _createItems()
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
        ),
      ],
    );
  }

  List<String> _createItems() {
    List<String> items = [""];
    for (var i = 0; i < 31; i++) {
      items.add("$i");
    }
    return items;
  }


}





