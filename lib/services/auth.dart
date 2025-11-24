import 'package:pokedex_joash/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthService{// this is connection to Firebase auth

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;//create an instance of firebase auth
  
  // 
  User? _userFromFirebaseUser(fb.User? user){
    return user != null ? User(uid: user.uid) : null;
  }// This turns the firbase user into a pokedex user 

  // This Stream will listen for Login/Logout changes , so when someone logins in or out 
  // the stream will send out an update 
  Stream<User?> get user {
    return _auth.authStateChanges()
    .map((fb.User? user) => _userFromFirebaseUser(user));
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try{// checks if email.password match in firebase
      fb.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      fb.User? user = result.user;
      return _userFromFirebaseUser(user);// this returns our pokedex user 
    }catch(e){
      print('Error signing in : $e');
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try{
      print(' Pokedex registration strating ');
      // set up email and password 
      fb.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      fb.User? user = result.user;

      // check if Pokedex account was created 

      if (user == null){
        print('User is null after registration ');
        return null;
      }
      print ('Pokedex user created with uid: ${user.uid}');

      return _userFromFirebaseUser(user);// return Pokedex user

    }catch(e){
      print('Error registering : $e');
      return null;
    }
  }
// Sign out
  Future<void> signOut() async {
    try{
      return await _auth.signOut();// this here tells firebase to end the session 
    }catch(e){
      print('Error signing out : $e');
      return null;
    }
  }

}