import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:econatu/src/user_preferences.dart';
import 'package:econatu/src/user_provider.dart';


class LoginPage extends StatefulWidget {  
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  

 // For Google Sign In
  final GoogleSignIn _googleSignIn = new GoogleSignIn(scopes: ['profile', 'email']);
  GoogleSignInAccount _currentUser;

// For Instagram Sign In 
  static String APP_ID = "";
  static String APP_SECRET = "";

  final usuario = UserPreferences();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox( height: MediaQuery.of(context).size.height * 0.10,),
          Center(
           child: Container(
             width: MediaQuery.of(context).size.width * 0.9,
             child: Image.asset('assets/EcoNatu_Logo_Final.jpg'),
                ),
              ),
          SizedBox( height: MediaQuery.of(context).size.height * 0.15,),
          Center(
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height:10.0),
                Container(
                      width: 250.0,
                        child: Align(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Color(0xffffffff),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                          Icon(FontAwesomeIcons.google,color: Color(0xffCE107C),),
                          SizedBox(width:10.0),
                          Text(
                          'Sign in with Google',
                          style: TextStyle(color: Colors.black,fontSize: 18.0),
                        ),
                        ],),
                        onPressed: () => _handleSignIn()
                                  // .then((FirebaseUser user) => print(user))
                                  // .catchError((e) => print(e)),
                      ),
                    )
                    ),

                    Container(
                      width: 250.0,
                        child: Align(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Color(0xffffffff),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                          Icon(FontAwesomeIcons.facebookF,color: Color(0xff4754de),),
                          SizedBox(width:10.0),
                          Text(
                          'Sign in with Facebook',
                          style: TextStyle(color: Colors.black,fontSize: 17.0),
                        ),
                        ],),
                        onPressed: () => _fbLogin(),
                      ),
                    )
                    ),
                    Container(
                      width: 250.0,
                        child: Align(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Color(0xffffffff),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                          Icon(FontAwesomeIcons.instagram ,),
                          SizedBox(width:10.0),
                          Text(
                          'Sign in with Instagram',
                          style: TextStyle(color: Colors.black,fontSize: 17.0),
                        ),
                        ],),
                        onPressed: () {},
                      ),
                    )
                    ),
            ],
          ),
          ),
        ],
      ),
    );
  }

  //Google Sign In
    Future<void> _handleSignIn() async{
    try{
    _currentUser =  await _googleSignIn.signIn();
    }catch(error){
      print(error); 
    }

    if (_currentUser != null) {
    usuario.username = _currentUser.displayName;
    usuario.photoURl = _currentUser.photoUrl; 
    usuario.email = _currentUser.email;
    usuario.loginType = "google";
    GoogleUser.guser.currentUser = _currentUser;
    Navigator.of(context).pushReplacementNamed('graph');

    }

  }

  //Facebook Login
  _fbLogin() async {

    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
                    'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=$token');
        final _profile = json.decode(graphResponse.body);
        usuario.loginType = "fb";
        usuario.username = _profile['name'];
        Map _picdata = _profile['picture']['data'];
        usuario.photoURl = _picdata['url']; 
        usuario.email = _profile['email'];
        Navigator.of(context).pushReplacementNamed('graph');
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("Cancelado por Usuario");
        break;
      case FacebookLoginStatus.error:
        print(result.errorMessage);
        break;
    }

  }

  //Instagram Login Function
  





}








//Second Section

// import 'package:econatu/src/user_preferences.dart';
// import 'package:econatu/src/user_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';



// GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   GoogleSignInAccount _currentUser;
//   final usuario = UserPreferences();


//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
//       setState(() {
//         _currentUser = account;
//       });
//     });
//     _googleSignIn.signInSilently();
    
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Sign in Demo'),
//       ),
//       body: Center(child: _buildBody()),
//     );
//   }

//   Widget _buildBody() {
//     if (_currentUser != null) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisSize: MainAxisSize.max,
//         children: <Widget>[
//           ListTile(
//             leading: GoogleUserCircleAvatar(
//               identity: _currentUser,
//             ),
//             title: Text(_currentUser.displayName ?? ''),
//             subtitle: Text(_currentUser.email ?? ''),
//           ),
//           RaisedButton(
//             onPressed: _handleSignOut,
//             child: Text('SIGN OUT'),
//           )
//         ],
//       );
//     }
//     else{
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisSize: MainAxisSize.max,
//         children: <Widget>[
//           Text('You are not signed in..'),
//           RaisedButton(
//             onPressed: _handleSignIn,
//             child: Text('SIGN IN'),
//           )
//         ],
//       );
//     }
//   }

//   Future<void> _handleSignIn() async{
//     try{
//     _currentUser =  await _googleSignIn.signIn();
//     }catch(error){
//       print(error);
//     }
    
    
//     usuario.username = _currentUser.displayName;
//     usuario.photoURl = _currentUser.photoUrl; 
//     usuario.email = _currentUser.email;
//     GoogleUser.guser.currentUser = _currentUser;

//     Navigator.of(context).pushReplacementNamed('graph');
    
//   }

//   // _handleSignIn() async {
//   //   await GoogleUser.guser.signIn();
//   //   setState(() {
//   //     _currentUser = GoogleUser.guser.currentUser;
      
//   //   });
//   //   Navigator.of(context).pushReplacementNamed('graph');
//   // }

//   // _handleSignOut() async {
//   //  await GoogleUser.guser.signOut();
//   // //  setState(() {
//   // //    _currentUser = GoogleUser.guser.currentUser;
//   // //  });
//   // }

//   Future<void> _handleSignOut() async{
//     _googleSignIn.disconnect();
//   }
// }