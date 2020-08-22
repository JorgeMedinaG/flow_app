import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email',]);

class GoogleUser {

  static GoogleSignInAccount _currentUser;
  //static Database _database; 
  
  //static final DBProvider db = DBProvider._();
  static final GoogleUser guser = GoogleUser._();

  //DBProvider._();
  GoogleUser._();

  // Future<Database> get database async {

  //   if (_database != null ) return _database; 

  //   _database = await initDB();
  //   return _database; 

  // }

  GoogleSignInAccount get currentUser {

    return _currentUser; 

  }

  set currentUser( GoogleSignInAccount user ) {
    _currentUser = user;
  }

  // Future<void> signIn() async {
  //   print("fun");
  //   try{
  //     _currentUser = await _googleSignIn.signIn();
  //     print("Done");
  //   }catch(error){
  //     print(error);
  //   }
  // }

  Future<void> signOut() async{
    await _googleSignIn.disconnect();
  }

}


class UserDetails {

  //static final DBProvider db = DBProvider._();
  // static final UserDetails userdetails = UserDetails._();

  //DBProvider._();
  // UserDetails._();

  final GoogleSignInAccount user;
  final String userName;
  //final String photoUrl;
  final String userEmail;
  //final List<ProviderDetails> providerData;

  UserDetails(this.user,this.userName,this.userEmail);
}