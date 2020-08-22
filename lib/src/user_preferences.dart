import 'package:shared_preferences/shared_preferences.dart';


class UserPreferences {

  static final UserPreferences _instancia = new UserPreferences._internal();

  factory UserPreferences() {
    return _instancia;
  }

  UserPreferences._internal();

  SharedPreferences _prefs;

  initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  // GET's and SET's of user information
  get username {
    return _prefs.getString('username') ?? '';
  }

  set username( String value ) {
    _prefs.setString('username', value);
  }

  get photoURl {
    return _prefs.getString('photoURl') ?? '';
  }

  set photoURl( String value ) {
    _prefs.setString('photoURl', value);
  }

  get email {
    return _prefs.getString('email') ?? '';
  }

  set email( String value ) {
    _prefs.setString('email', value);
  }

  get loginType {
    return _prefs.getString('loginType') ?? '';
  }

  set loginType( String value ) {
    _prefs.setString('loginType', value);
  }


  
  // GET and SET of the router ip
  get routerip {
    return _prefs.getString('routerip') ?? '';
  }

  set routerip( String value ) {
    _prefs.setString('routerip', value);
  }

  // GET and SET of the billing date
  get closedate {
    return _prefs.getString('closedate') ?? '';
  }

  set closedate( String value ) {
    _prefs.setString('closedate', value);
  }

  // GET and SET of the billing date
  get lastUpdate {
    return _prefs.getString('lastUpdate') ?? '';
  }

  set lastUpdate( String value ) {
    _prefs.setString('lastUpdate', value);
  }




}

